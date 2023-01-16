require 'sivel2_sjr/concerns/models/consactividadcaso'

class Sivel2Sjr::Consactividadcaso < ActiveRecord::Base
  include Sivel2Sjr::Concerns::Models::Consactividadcaso

  scope :filtro_persona_tipodocumento, lambda { |f|
      where(persona_tipodocumento: f)
  }

  def self.consulta
    "SELECT actividad_id*50000+persona.id AS id,
        caso.id AS caso_id, 
        actividad_id,
        victima.id AS victima_id,
        CASE WHEN casosjr.contacto_id=persona.id THEN 1 ELSE 0 END 
          AS es_contacto,
        actividad.fecha AS actividad_fecha,
        (SELECT nombre FROM msip_oficina 
          WHERE msip_oficina.id=actividad.oficina_id LIMIT 1) 
          AS actividad_oficina,
        (SELECT nusuario FROM usuario 
          WHERE usuario.id=actividad.usuario_id LIMIT 1)
          AS actividad_responsable,
        ARRAY_TO_STRING(ARRAY(SELECT nombre FROM cor1440_gen_proyectofinanciero
          WHERE cor1440_gen_proyectofinanciero.id IN
          (SELECT proyectofinanciero_id FROM cor1440_gen_actividad_proyectofinanciero AS apf WHERE apf.actividad_id=actividad.id)), ',') 
          AS actividad_convenios,
        persona.id AS persona_id,
        persona.nombres AS persona_nombres,
        persona.apellidos AS persona_apellidos,
        persona.tdocumento_id AS persona_tipodocumento,
        caso.memo AS caso_memo,
        casosjr.fecharec AS caso_fecharec
        FROM public.cor1440_gen_asistencia AS asi
        INNER JOIN msip_persona AS persona ON persona.id=asi.persona_id 
        INNER JOIN cor1440_gen_actividad AS actividad 
          ON actividad_id=actividad.id
        INNER JOIN msip_oficina AS oficinaac 
          ON oficinaac.id=actividad.oficina_id
        INNER JOIN sivel2_gen_victima AS victima ON victima.id_persona=persona.id
        INNER JOIN sivel2_gen_caso AS caso ON victima.id_caso=caso.id
        INNER JOIN sivel2_sjr_casosjr AS casosjr ON caso.id=casosjr.id_caso
    "
  end
end
