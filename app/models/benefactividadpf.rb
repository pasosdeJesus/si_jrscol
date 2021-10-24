class Benefactividadpf < ActiveRecord::Base
  include Sip::Modelo

  scope :filtro_persona_nombre, lambda { |d|
    where("unaccent(persona_nombre) ILIKE '%' || unaccent(?) || '%'", d)
  }

  scope :filtro_persona_identificacion, lambda { |iden|
    where("unaccent(persona_identificacion) ILIKE '%' || unaccent(?) || '%'", iden)
  }

  scope :filtro_persona_sexo, lambda { |sexo|
    where(persona_sexo: sexo)
  }

  scope :filtro_rangoedadac_nombre, lambda { |rac|
    where(rangoedadac_nombre: rac)
  }


  # Genera consulta
  # @params ordenar_por Criterio de ordenamiento
  # @params pf_id Entero con dentificación del proyecto financiero  o nil
  # @params oficina_id Entero con identificación de la oficina o nil
  # @params fechaini Fecha inicial en formato estándar o nil
  # @params fechafin Fecha final en formato estándar o nil
  #
  def self.crea_consulta(ordenar_por = nil, pf_id, oficina_id, 
                    fechaini, fechafin)
    if ARGV.include?("db:migrate")
      return
    end
    contarb_actividad = Cor1440Gen::Actividad.all
    if oficina_id
      contarb_actividad = contarb_actividad.where(oficina_id: oficina_id)
    end
    if pf_id
      contarb_actividad = contarb_actividad.where(
        'cor1440_gen_actividad.id IN 
        (SELECT actividad_id FROM cor1440_gen_actividad_proyectofinanciero
          WHERE proyectofinanciero_id=?)', pf_id).where(
            'cor1440_gen_actividad.id IN 
        (SELECT actividad_id FROM cor1440_gen_actividad_actividadpf)')
    end
    if fechaini
      contarb_actividad = contarb_actividad.where(
        'cor1440_gen_actividad.fecha >= ?', fechaini)
    end
    if fechafin
      contarb_actividad = contarb_actividad.where(
        'cor1440_gen_actividad.fecha <= ?', fechafin)
    end

    contarb_listaac = Cor1440Gen::Actividadpf.where(
      proyectofinanciero_id: pf_id).order(:nombrecorto) 

    contarpro = Cor1440Gen::Actividadpf.where(
      proyectofinanciero_id: pf_id)
    asistencias = Cor1440Gen::Asistencia.where(
      actividad_id: contarb_actividad)
    personasis = asistencias.select(:persona_id)
    actividades = asistencias.select(:actividad_id)

    selbenef = Benefactividadpf.subasis(personasis, actividades, contarpro)
    File.open('/tmp/ba.sql', 'w') do |ma|
      ma.puts selbenef
    end

    ActiveRecord::Base.connection.execute(
      "DROP MATERIALIZED VIEW IF EXISTS benefactividadpf;"\
      "CREATE MATERIALIZED VIEW benefactividadpf AS "\
      "  #{selbenef};"
    )
    Benefactividadpf.reset_column_information
  end # def crea_consulta

  def self.subasis(personas, actividades, actividadespf)
    c="SELECT sub.*, 
      (SELECT nombre FROM cor1440_gen_rangoedadac AS red
       WHERE id=CASE 
         WHEN (red.limiteinferior IS NULL OR 
           red.limiteinferior<=sub.edad_en_actividad) AND 
           (red.limitesuperior IS NULL OR
           red.limitesuperior>=sub.edad_en_actividad) THEN
           red.id
         ELSE
           7 -- SIN INFORMACION
       END LIMIT 1) AS rangoedadac_nombre
      FROM (SELECT p.id AS persona_id,
       TRIM(TRIM(p.nombres) || ' '  ||
         TRIM(p.apellidos)) AS persona_nombre,
       public.sip_edad_de_fechanac_fecharef(
         p.anionac, p.mesnac, p.dianac,
       EXTRACT(YEAR FROM a.fecha)::integer,
       EXTRACT(MONTH from a.fecha)::integer,
       EXTRACT(DAY FROM a.fecha)::integer) AS edad_en_actividad,
       TRIM(COALESCE(td.sigla || ':', '') ||
         COALESCE(p.numerodocumento, '')) AS persona_identificacion,
       p.sexo AS persona_sexo
    " 
    if actividadespf.count > 0
      c+= ", "
      codigos = []
      actividadespf.each.with_index(1) do |apf, ind|
        cod = (apf.objetivopf ? apf.objetivopf.numero : '') + 
          (apf.resultadopf ? apf.resultadopf.numero : '') + 
          (apf.nombrecorto )
        if codigos.include? cod 
          cod = cod + "_" + ind.to_s 
        end
        codigos.push(cod)
        c += '(
           SELECT COUNT(*) FROM cor1440_gen_asistencia AS asistencia
             JOIN cor1440_gen_actividad_actividadpf AS aapf 
               ON aapf.actividad_id=asistencia.actividad_id
             WHERE aapf.actividadpf_id = ' + apf.id.to_s + '  
             AND persona_id = p.id
             AND asistencia.actividad_id IN (' + actividades.to_sql + ') 
        ) AS "'+ cod +'"' 
        if apf != actividadespf.last
          c += ', '
        end
      end
    end
    c+="FROM sip_persona AS p
        JOIN cor1440_gen_asistencia AS asis ON asis.persona_id=p.id 
        LEFT JOIN sip_tdocumento AS td ON td.id=p.tdocumento_id
        JOIN cor1440_gen_actividad AS a ON asis.actividad_id=a.id
        WHERE p.id IN (#{personas.to_sql}) 
        GROUP BY persona_identificacion, p.id, edad_en_actividad) AS sub
    "
  end
end
