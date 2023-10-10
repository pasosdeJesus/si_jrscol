require 'sivel2_gen/concerns/models/conscaso'

class Sivel2Gen::Conscaso < ActiveRecord::Base
  include Sivel2Gen::Concerns::Models::Conscaso

  has_one :casosjr, class_name: 'Sivel2Sjr::Casosjr',
    foreign_key: "caso_id", primary_key: 'caso_id'

  scope :filtro_apellidossp, lambda { |a|
    joins(:casosjr).joins(:persona).
      where('sivel2_sjr_casosjr.contacto_id = msip_persona.id ' +
            'AND msip_persona.apellidos ILIKE \'%' +
            ActiveRecord::Base.connection.quote_string(a) + '%\'')
  }

  scope :filtro_atenciones_fechafin, lambda { |fecha|
    where('caso_id IN (SELECT casosjr_id FROM 
              sivel2_sjr_actividad_casosjr JOIN cor1440_gen_actividad
              ON sivel2_sjr_actividad_casosjr.actividad_id =
                cor1440_gen_actividad.id
              WHERE
                cor1440_gen_actividad.fecha <= ?)', fecha)
  }

  scope :filtro_atenciones_fechaini, lambda { |fecha|
    where('caso_id IN (SELECT casosjr_id FROM 
              sivel2_sjr_actividad_casosjr JOIN cor1440_gen_actividad
              ON sivel2_sjr_actividad_casosjr.actividad_id =
                cor1440_gen_actividad.id
              WHERE
                cor1440_gen_actividad.fecha >= ?)', fecha)
  }

  scope :filtro_departamento_id, lambda { |id|
    where('caso_id IN (SELECT caso_id
                    FROM public.sivel2_sjr_migracion
                    JOIN public.msip_ubicacionpre ON
                    sivel2_sjr_migracion.salidaubicacionpre_id=msip_ubicacionpre.id
                    WHERE msip_ubicacionpre.departamento_id = ?)', id)
  }

  scope :filtro_fecharecfin, lambda { |f|
    where('sivel2_gen_conscaso.fecharec <= ?', f)
  }

  scope :filtro_fecharecini, lambda { |f|
    where('sivel2_gen_conscaso.fecharec >= ?', f)
  }

  scope :filtro_nombressp, lambda { |a|
    joins(:casosjr).joins(:persona).
      where('sivel2_sjr_casosjr.contacto_id = msip_persona.id ' +
            'AND msip_persona.nombres ILIKE \'%' +
            ActiveRecord::Base.connection.quote_string(a) + '%\'')
  }

  scope :filtro_nusuario, lambda { |n|
    where('sivel2_gen_conscaso.nusuario = ?', n)
  }

  scope :filtro_oficina_id, lambda { |id|
    where('sivel2_sjr_casosjr.oficina_id = ?', id).
      joins(:casosjr)
  }

  scope :filtro_statusmigratorio_id, lambda { |id|
    where('sivel2_sjr_casosjr.estatusmigratorio_id = ?', id).
      joins(:casosjr)
  }

  scope :filtro_territorial_id, lambda { |id|
    where('msip_oficina.territorial_id = ?', id).
      joins(:casosjr).joins("JOIN msip_oficina "\
                            "ON msip_oficina.id=sivel2_sjr_casosjr.oficina_id")
  }

  scope :filtro_ultimaatencion_fechafin, lambda { |f|
    where('sivel2_gen_conscaso.ultimaatencion_fecha <= ?', f)
  }

  scope :filtro_ultimaatencion_fechaini, lambda { |f|
    where('sivel2_gen_conscaso.ultimaatencion_fecha >= ?', f)
  }



  scope :ordenar_por, lambda { |campo|
    critord = ""
    case campo.to_s
    when /^codigo/
      critord ="sivel2_gen_conscaso.caso_id asc"
    when /^codigodesc/
      critord = "sivel2_gen_conscaso.caso_id desc"
    when /^fecharec/
      critord = "sivel2_gen_conscaso.fecharec desc"
    when /^fecharecasc/
      critord = "sivel2_gen_conscaso.fecharec asc"
    when /^fecha/
      critord = "sivel2_gen_conscaso.fecha asc"
    when /^fechadesc/
      critord = "sivel2_gen_conscaso.fecha desc"
    when /^ubicacion/
      critord = "sivel2_gen_conscaso.ubicaciones asc"
    when /^ubicaciondesc/
      critord = "sivel2_gen_conscaso.ubicaciones desc"
    when /^ultimaatencion_fecha/
      critord = "sivel2_gen_conscaso.ultimaatencion_fecha desc"
    when /^ultimaatencion_fechaasc/
      critord = "sivel2_gen_conscaso.ultimaatencion_fecha asc"
    else
      raise(ArgumentError, "Ordenamiento invalido: #{ campo.inspect }")
    end
    order(critord + ', sivel2_gen_conscaso.caso_id')
  }

   scope :filtro_expulsion_pais_id, lambda { |id|
    where('caso_id IN (SELECT caso_id FROM public.emblematica 
          WHERE emblematica.expulsionpais_id = ?)', id)
  }

  scope :filtro_expulsion_departamento_id, lambda { |id|
    where('caso_id IN (SELECT caso_id FROM public.emblematica 
          WHERE emblematica.expulsiondepartamento_id = ?)', id)
  }

  scope :filtro_expulsion_municipio_id, lambda { |id|
    where('caso_id IN (SELECT caso_id FROM public.emblematica 
          WHERE emblematica.expulsionmunicipio_id = ?)', id)
  }

  scope :filtro_llegada_pais_id, lambda { |id|
    where('caso_id IN (SELECT caso_id FROM public.emblematica 
          WHERE emblematica.llegadapais_id = ?)', id)
  }

  scope :filtro_llegada_departamento_id, lambda { |id|
    where('caso_id IN (SELECT caso_id FROM public.emblematica 
          WHERE emblematica.llegadadepartamento_id = ?)', id)
  }

  scope :filtro_llegada_municipio_id, lambda { |id|
    where('caso_id IN (SELECT caso_id FROM public.emblematica 
          WHERE emblematica.llegadamunicipio_id = ?)', id)
  }

  scope :filtro_numerodocumento, lambda { |a|
    joins('JOIN sivel2_gen_victima ON sivel2_gen_victima.caso_id='+
          'sivel2_gen_conscaso.caso_id').joins('JOIN msip_persona ON '+
          'sivel2_gen_victima.persona_id = msip_persona.id')
      .where('msip_persona.numerodocumento=?', a)
  }

  scope :filtro_tdocumento, lambda { |a|
    joins('JOIN sivel2_gen_victima ON sivel2_gen_victima.caso_id='+
          'sivel2_gen_conscaso.caso_id').joins('JOIN msip_persona ON '+
          'sivel2_gen_victima.persona_id = msip_persona.id')
      .where('msip_persona.tdocumento_id=?', a.to_i)
  }


  # Refresca vista materializa sivel2_gen_conscaso
  # Si cambia la definición de la vista borre sivel2_gen_conscaso1 y
  # sivel2_gen_conscaso para que esta función las genere modificadas
  def self.refresca_conscaso
    if !ActiveRecord::Base.connection.data_source_exists? 'sivel2_sjr_ultimaatencion_aux'
      ActiveRecord::Base.connection.execute(
        "CREATE OR REPLACE VIEW sivel2_sjr_ultimaatencion_aux AS 
           SELECT DISTINCT v1.caso_id AS caso_id, a1.fecha, 
             a1.id AS actividad_id
           FROM  public.cor1440_gen_asistencia AS asi1
             JOIN public.cor1440_gen_actividad AS a1 ON asi1.actividad_id=a1.id
             JOIN public.msip_persona as p1 ON p1.id=asi1.persona_id
             JOIN public.sivel2_gen_victima as v1 ON v1.persona_id=p1.id
             WHERE (v1.caso_id, a1.fecha, a1.id) IN
           (SELECT v2.caso_id, a2.fecha, a2.id AS actividad_id
             FROM public.cor1440_gen_asistencia AS asi2
             JOIN public.cor1440_gen_actividad AS a2 ON asi2.actividad_id=a2.id
             JOIN public.msip_persona as p2 ON p2.id=asi2.persona_id
             JOIN public.sivel2_gen_victima as v2 ON v2.persona_id=p2.id
             WHERE v2.caso_id=v1.caso_id
             ORDER BY 2 DESC, 3 DESC LIMIT 1);"
      )
    end
    if !ActiveRecord::Base.connection.data_source_exists? 'sivel2_sjr_ultimaatencion'
      ActiveRecord::Base.connection.execute(
        "CREATE OR REPLACE VIEW sivel2_sjr_ultimaatencion AS 
           SELECT casosjr.caso_id AS caso_id, 
             a.id AS actividad_id,
             a.fecha AS fecha, 
             a.objetivo, 
             a.resultado,
             msip_edad_de_fechanac_fecharef(contacto.anionac, contacto.mesnac, 
               contacto.dianac, CAST(EXTRACT(YEAR FROM a.fecha) AS INTEGER),
               CAST(EXTRACT(MONTH FROM a.fecha) AS INTEGER),
               CAST(EXTRACT(DAY FROM a.fecha) AS INTEGER) ) AS contacto_edad
             FROM sivel2_sjr_ultimaatencion_aux AS uaux 
             JOIN public.cor1440_gen_actividad AS a ON uaux.actividad_id=a.id 
             JOIN public.sivel2_sjr_casosjr AS casosjr ON 
               uaux.caso_id=casosjr.caso_id 
             JOIN public.msip_persona AS contacto ON
               contacto.id=casosjr.contacto_id"
      )
    end

    if !ActiveRecord::Base.connection.data_source_exists? 'sivel2_gen_conscaso'
      ActiveRecord::Base.connection.execute(
        "CREATE OR REPLACE VIEW emblematica1
        AS SELECT *
        FROM ((SELECT 
          caso.id AS caso_id,
          caso.fecha,
          'desplazamiento' AS despomigracion,
          desplazamiento.id AS despomigracion_id,
          ubicacionpreex.id AS expulsionubicacionpre_id,
          paisex.id AS expulsionpais_id,
          paisex.nombre AS expulsionpais,
          departamentoex.id AS expulsiondepartamento_id,
          departamentoex.nombre AS expulsiondepartamento,
          municipioex.id AS expulsionmunicipio_id,
          municipioex.nombre AS expulsionmunicipio,
          COALESCE(municipioex.nombre, '') || ' / ' ||
            COALESCE(departamentoex.nombre, '') || ' / ' ||
            COALESCE(paisex.nombre, '') AS expulsionubicacionpre,
          ubicacionprel.id AS llegadaubicacionpre_id,
          paisl.id AS llegadapais_id,
          paisl.nombre AS llegadapais,
          departamentol.id AS llegadadepartamento_id,
          departamentol.nombre AS llegadadepartamento,
          municipiol.id AS llegadamunicipio_id,
          municipiol.nombre AS llegadamunicipio,
          COALESCE(municipiol.nombre, '') || ' / ' ||
            COALESCE(departamentol.nombre, '') || ' / ' ||
            COALESCE(paisl.nombre, '') AS llegadaubicacionpre
          FROM public.sivel2_sjr_desplazamiento AS desplazamiento
          JOIN sivel2_gen_caso AS caso ON
            desplazamiento.caso_id=caso.id
            AND desplazamiento.fechaexpulsion=caso.fecha
          LEFT JOIN public.msip_ubicacionpre AS ubicacionpreex
            ON ubicacionpreex.id=desplazamiento.expulsionubicacionpre_id
          LEFT JOIN public.msip_pais AS paisex
            ON ubicacionpreex.pais_id=paisex.id
          LEFT JOIN public.msip_departamento AS departamentoex
            ON ubicacionpreex.departamento_id=departamentoex.id
          LEFT JOIN public.msip_municipio AS municipioex
            ON ubicacionpreex.municipio_id=municipioex.id
          LEFT JOIN public.msip_ubicacionpre AS ubicacionprel
            ON ubicacionprel.id=desplazamiento.llegadaubicacionpre_id
          LEFT JOIN public.msip_pais AS paisl
            ON ubicacionprel.pais_id=paisl.id
          LEFT JOIN public.msip_departamento AS departamentol
            ON ubicacionprel.departamento_id=departamentol.id
          LEFT JOIN public.msip_municipio AS municipiol
            ON ubicacionprel.municipio_id=municipiol.id
          ORDER BY desplazamiento.id
          ) UNION
          (SELECT 
          caso.id AS caso_id,
          caso.fecha,
          'migracion' AS despomigracion,
          migracion.id AS despomigracion_id,
          ubicacionpres.id AS expulsionubicacionpre_id,
          paiss.id AS expulsionpais_id,
          paiss.nombre AS expulsionpais,
          departamentos.id AS expulsiondepartamento_id,
          departamentos.nombre AS expulsiondepartamento,
          municipios.id AS expulsionmunicipio_id,
          municipios.nombre AS expulsionmunicipio,
          COALESCE(municipios.nombre, '') || ' / ' ||
            COALESCE(departamentos.nombre, '') || ' / ' ||
            COALESCE(paiss.nombre, '') AS expulsionubicacionpre,
          ubicacionprel.id AS llegadaubicacionpre_id,
          paisl.id AS llegadapais_id,
          paisl.nombre AS llegadapais,
          departamentol.id AS llegadadepartamento_id,
          departamentol.nombre AS llegadadepartamento,
          municipiol.id AS llegadamunicipio_id,
          municipiol.nombre AS llegadamunicipio,
          COALESCE(municipiol.nombre, '') || ' / ' ||
            COALESCE(departamentol.nombre, '') || ' / ' ||
            COALESCE(paisl.nombre, '') AS llegadaubicacionpre
          FROM public.sivel2_sjr_migracion AS migracion
          JOIN sivel2_gen_caso AS caso ON
            migracion.caso_id=caso.id
            AND migracion.fechasalida=caso.fecha
          LEFT JOIN public.msip_ubicacionpre AS ubicacionpres
            ON ubicacionpres.id=migracion.salidaubicacionpre_id
          LEFT JOIN public.msip_pais AS paiss
            ON ubicacionpres.pais_id=paiss.id
          LEFT JOIN public.msip_departamento AS departamentos
            ON ubicacionpres.departamento_id=departamentos.id
          LEFT JOIN public.msip_municipio AS municipios
            ON ubicacionpres.municipio_id=municipios.id
          LEFT JOIN public.msip_ubicacionpre AS ubicacionprel
            ON ubicacionprel.id=migracion.llegadaubicacionpre_id
          LEFT JOIN public.msip_pais AS paisl
            ON ubicacionprel.pais_id=paisl.id
          LEFT JOIN public.msip_departamento AS departamentol
            ON ubicacionprel.departamento_id=departamentol.id
          LEFT JOIN public.msip_municipio AS municipiol
            ON ubicacionprel.municipio_id=municipiol.id
          ORDER BY migracion.id
          ) 
          ) AS sub
        ORDER BY caso_id
      ")
      ActiveRecord::Base.connection.execute(
        "CREATE OR REPLACE VIEW emblematica
        AS SELECT 
          caso.id AS caso_id,
          caso.fecha,
          (SELECT despomigracion FROM emblematica1 WHERE caso_id=caso.id LIMIT 1) AS despomigracion,
          (SELECT despomigracion_id FROM emblematica1 WHERE caso_id=caso.id LIMIT 1) AS despomigracion_id,
          (SELECT expulsionubicacionpre_id FROM emblematica1 WHERE caso_id=caso.id LIMIT 1) AS expulsionubicacionpre_id,
          (SELECT expulsionpais_id FROM emblematica1 WHERE caso_id=caso.id LIMIT 1) AS expulsionpais_id,
          (SELECT expulsionpais FROM emblematica1 WHERE caso_id=caso.id LIMIT 1) AS expulsionpais,
          (SELECT expulsiondepartamento_id FROM emblematica1 WHERE caso_id=caso.id LIMIT 1) AS expulsiondepartamento_id,
          (SELECT expulsiondepartamento FROM emblematica1 WHERE caso_id=caso.id LIMIT 1) AS expulsiondepartamento,
          (SELECT expulsionmunicipio_id FROM emblematica1 WHERE caso_id=caso.id LIMIT 1) AS expulsionmunicipio_id,
          (SELECT expulsionmunicipio FROM emblematica1 WHERE caso_id=caso.id LIMIT 1) AS expulsionmunicipio,
          (SELECT expulsionubicacionpre FROM emblematica1 WHERE caso_id=caso.id LIMIT 1) AS expulsionubicacionpre,
          (SELECT llegadaubicacionpre_id FROM emblematica1 WHERE caso_id=caso.id LIMIT 1) AS llegadaubicacionpre_id,
          (SELECT llegadapais_id FROM emblematica1 WHERE caso_id=caso.id LIMIT 1) AS llegadapais_id,
          (SELECT llegadapais FROM emblematica1 WHERE caso_id=caso.id LIMIT 1) AS llegadapais,
          (SELECT llegadadepartamento_id FROM emblematica1 WHERE caso_id=caso.id LIMIT 1) AS llegadadepartamento_id,
          (SELECT llegadadepartamento FROM emblematica1 WHERE caso_id=caso.id LIMIT 1) AS llegadadepartamento,
          (SELECT llegadamunicipio_id FROM emblematica1 WHERE caso_id=caso.id LIMIT 1) AS llegadamunicipio_id,
          (SELECT llegadamunicipio FROM emblematica1 WHERE caso_id=caso.id LIMIT 1) AS llegadamunicipio,
          (SELECT llegadaubicacionpre FROM emblematica1 WHERE caso_id=caso.id LIMIT 1) AS llegadaubicacionpre
          FROM sivel2_gen_caso AS caso
        ")

      ActiveRecord::Base.connection.execute(
        "CREATE OR REPLACE VIEW sivel2_gen_conscaso1 
        AS SELECT casosjr.caso_id AS caso_id, 
        (contacto.nombres || ' ' || contacto.apellidos) AS contacto,
        ultimaatencion.fecha AS ultimaatencion_fecha,
        casosjr.fecharec,
        oficina.nombre AS oficina,
        usuario.nusuario,
        caso.fecha AS fecha,
        (SELECT expulsionubicacionpre FROM 
          emblematica WHERE emblematica.caso_id=caso.id LIMIT 1) AS expulsion,
        (SELECT llegadaubicacionpre FROM 
          emblematica WHERE emblematica.caso_id=caso.id LIMIT 1) AS llegada,
        caso.memo AS memo
        FROM public.sivel2_sjr_casosjr AS casosjr 
          JOIN public.sivel2_gen_caso AS caso ON casosjr.caso_id = caso.id 
          JOIN public.msip_oficina AS oficina ON oficina.id=casosjr.oficina_id
          JOIN public.usuario ON usuario.id = casosjr.asesor
          JOIN public.msip_persona AS contacto ON contacto.id=casosjr.contacto_id
          JOIN public.sivel2_gen_victima AS vcontacto ON 
            vcontacto.persona_id = contacto.id AND vcontacto.caso_id = caso.id
          LEFT JOIN public.sivel2_sjr_ultimaatencion AS ultimaatencion ON
            ultimaatencion.caso_id = caso.id
      ")
      ActiveRecord::Base.connection.execute(
        "CREATE MATERIALIZED VIEW sivel2_gen_conscaso 
        AS SELECT caso_id, contacto, 
          fecharec, oficina, nusuario, fecha, expulsion, llegada,
          ultimaatencion_fecha,
          memo, to_tsvector('spanish', unaccent(caso_id || ' ' || contacto || 
            ' ' || replace(fecharec::text, '-', ' ') || 
            ' ' || oficina || ' ' || nusuario || ' ' || 
            replace(fecha::text, '-', ' ') || ' ' ||
            COALESCE(expulsion, '')  || ' ' || COALESCE(llegada, '') || ' ' || 
            replace(COALESCE(ultimaatencion_fecha::text, ''), '-', ' ')
            || ' ' || memo )) as q
        FROM public.sivel2_gen_conscaso1"
      );
      ActiveRecord::Base.connection.execute(
        "CREATE INDEX busca_conscaso ON sivel2_gen_conscaso USING gin(q);"
      )
    else
      ActiveRecord::Base.connection.execute(
        "REFRESH MATERIALIZED VIEW sivel2_gen_conscaso"
      )
    end
  end

  def self.porsjrc
    "porsjrc"
  end

end

