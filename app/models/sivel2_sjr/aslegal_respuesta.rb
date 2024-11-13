module Sivel2Sjr
  # Obsoleto
  class AslegalRespuesta < ActiveRecord::Base

    self.table_name = "sivel2_sjr_aslegal_respuesta"

    belongs_to :aslegal, class_name: "Sivel2Sjr::Aslegal", 
      foreign_key: "aslegal_id", optional: false
    belongs_to :respuesta, class_name: "Sivel2Sjr::Respuesta", 
      foreign_key: "respuesta_id", optional: false
  end
end
