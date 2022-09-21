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

    Benefactividadpf.connection.execute <<-SQL
      CREATE OR REPLACE VIEW benefext AS 
        SELECT DISTINCT actividad_id, persona_id, persona_actividad_perfil
        FROM (
          SELECT ac.id AS actividad_id, v.id_persona AS persona_id, '' AS persona_actividad_perfil
          FROM cor1440_gen_actividad AS ac 
          JOIN sivel2_sjr_actividad_casosjr AS accas ON accas.actividad_id=ac.id 
          JOIN sivel2_gen_victima as v on v.id_caso=accas.casosjr_id 
          UNION
          SELECT ac.id AS actividad_id, asis.persona_id, 
            COALESCE(porg.nombre) AS person_actividad_perfil
          FROM cor1440_gen_actividad AS ac 
          JOIN cor1440_gen_asistencia AS asis ON asis.actividad_id=ac.id
          LEFT JOIN sip_perfilorgsocial AS porg ON porg.id=asis.perfilorgsocial_id
        ) as sub
      ;

      CREATE OR REPLACE VIEW benefext2 AS 
      SELECT a.fecha AS actividad_fecha,
        o.nombre AS actividad_oficina,
        t.sigla AS persona_tipodocumento,
        p.numerodocumento AS persona_numerodocumento,
        p.nombres AS persona_nombres,
        p.apellidos AS persona_apellidos,
        p.sexo AS persona_sexo,
        p.dianac AS persona_dianac,
        p.mesnac AS persona_mesnac,
        p.anionac AS persona_anionac,
        public.sip_edad_de_fechanac_fecharef(
          p.anionac, p.mesnac, p.dianac,
          EXTRACT(YEAR FROM a.fecha)::integer,
          EXTRACT(MONTH from a.fecha)::integer,
          EXTRACT(DAY FROM a.fecha)::integer) AS persona_actividad_edad,
        b.persona_actividad_perfil,
        COALESCE(mun.nombre, '') || ' / ' || COALESCE(dep.nombre, '') AS actividad_municipio,
        a.id AS actividad_id,
        ARRAY_TO_STRING(ARRAY(SELECT DISTINCT id_caso
          FROM sivel2_gen_victima
          WHERE id_persona=p.id), ',') AS persona_caso_ids,
        p.id AS persona_id
        FROM benefext AS b 
        JOIN cor1440_gen_actividad AS a ON a.id=b.actividad_id
        JOIN sip_oficina AS o ON  o.id=a.oficina_id
        JOIN sip_persona AS p ON p.id=b.persona_id
        LEFT JOIN sip_tdocumento AS t ON t.id=p.tdocumento_id
        LEFT JOIN sip_ubicacionpre AS u ON u.id=a.ubicacionpre_id
        LEFT JOIN sip_departamento AS dep on dep.id=u.departamento_id
        LEFT JOIN sip_municipio AS mun on mun.id=u.municipio_id
      ;
    SQL


    wherebe = "TRUE" 
    if oficina_id
      obof = Sip::Oficina.find(oficina_id)
      wherebe << " AND be.actividad_oficina = '#{Sip::SqlHelper.escapar(obof.nombre)}'"
    end
    if pf_id
      wherebe << " AND be.actividad_id IN 
        (SELECT actividad_id FROM cor1440_gen_actividad_proyectofinanciero
          WHERE proyectofinanciero_id=#{pf_id.to_i})"
    end
    if fechaini
      wherebe << " AND be.actividad_fecha >= '#{Sip::SqlHelper.escapar(fechaini)}'"
    end
    if fechafin
      wherebe << " AND be.actividad_fecha <= '#{Sip::SqlHelper.escapar(fechafin)}'"
    end

    contarb_listaac = Cor1440Gen::Actividadpf.where(
      proyectofinanciero_id: pf_id).order(:nombrecorto)

    contarpro = Cor1440Gen::Actividadpf.where(
      proyectofinanciero_id: pf_id)

    selbenef = Benefactividadpf.subasis(wherebe, contarpro)
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



  def self.subasis(wherebe, actividadespf)

    c="
    SELECT be.*, ARRAY_TO_STRING(
      ARRAY( SELECT DISTINCT apf.nombrecorto || ': ' || apf.titulo 
        FROM cor1440_gen_actividadpf AS apf
        WHERE apf.id IN (SELECT actividadpf_id 
          FROM cor1440_gen_actividad_actividadpf AS aapf
          WHERE aapf.actividad_id=be.actividad_id)), '; ') AS actividad_actividadesml
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
        c += "(SELECT COUNT(*) FROM 
          cor1440_gen_actividad_actividadpf AS aapf
          WHERE aapf.actividad_id=be.actividad_id 
          AND aapf.actividadpf_id=#{apf.id}) AS \"#{cod}\""
        if apf != actividadespf.last
          c += ', '
        end
      end
    end
    c += " FROM benefext2 AS be 
      WHERE #{wherebe};"
    return c

  end


  def presenta(atr)
    m =/^(.*)_enlace$/.match(atr.to_s)
    if m && !self[m[1]].nil? && !self[m[1]+"_ids"].nil?
        if self[m[1]].to_i == 0
          r = "0"
        else
          bids = self[m[1]+"_ids"].join(',')
          r="<a href='#{Rails.application.routes.url_helpers.sip_path +
                        'actividades?filtro[busid]=' + bids}'"\
                        " target='_blank'>"\
                        "#{self[m[1]]}"\
                        "</a>".html_safe
        end
        return r.html_safe
    end
    return presenta_gen(atr)
  end


end
