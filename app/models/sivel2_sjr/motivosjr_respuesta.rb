module Sivel2Sjr
  # Obsoleto
  class MotivosjrRespuesta < ActiveRecord::Base

    self.table_name = "sivel2_sjr_motivosjr_respuesta"

    belongs_to :motivosjr, class_name: "Sivel2Sjr::Motivosjr", 
      foreign_key: "motivosjr_id", validate: true, optional: false
    belongs_to :respuesta, class_name: "Sivel2Sjr::Respuesta", 
      foreign_key: "respuesta_id", validate: true, optional: false
  end
end
