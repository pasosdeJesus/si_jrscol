module Sivel2Sjr
  class DerechoRespuesta < ActiveRecord::Base

    self.table_name = "sivel2_sjr_derecho_respuesta"

    belongs_to :derecho, class_name: "Sivel2Sjr::Derecho", 
      foreign_key: "derecho_id", validate: true, optional: false
    belongs_to :respuesta, class_name: "Sivel2Sjr::Respuesta", 
      foreign_key: "respuesta_id", validate: true, optional: false
  end
end
