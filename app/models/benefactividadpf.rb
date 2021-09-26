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

  def self.subasis(lisp, lisa, actividadespf)
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
       p.sexo AS persona_sexo" 
       if actividadespf.count > 0
         c+= ", "   
         actividadespf.each do |apf|
           cod = apf.objetivopf.numero + apf.resultadopf.numero + apf.nombrecorto
           c+='(
                 SELECT COUNT(*) FROM cor1440_gen_asistencia AS asistencia
                 JOIN cor1440_gen_actividad_actividadpf AS aapf ON aapf.actividad_id=asistencia.actividad_id
                 WHERE aapf.actividadpf_id = ' + apf.id.to_s + '  
                 AND persona_id = p.id
                 AND asistencia.actividad_id IN (' + lisa + ') 
                 ) AS "'+ cod +'"' 
                  if apf != actividadespf.last
                    c += ', '
                  end
          end
        end
       c+="
       FROM sip_persona AS p
     JOIN cor1440_gen_asistencia AS asis ON asis.persona_id=p.id 
     LEFT JOIN sip_tdocumento AS td ON td.id=p.tdocumento_id
     JOIN cor1440_gen_actividad AS a ON asis.actividad_id=a.id
     WHERE p.id IN (#{lisp}) GROUP BY persona_identificacion, p.id, edad_en_actividad) AS sub
    "
  end
end
