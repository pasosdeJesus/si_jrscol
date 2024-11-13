module Sivel2Sjr
  # Obsoleto
  class AspsicosocialRespuesta < ActiveRecord::Base

    self.table_name = "sivel2_sjr_aspsicosocial_respuesta"

    belongs_to :aspsicosocial, class_name: "Sivel2Sjr::Aspsicosocial", 
      foreign_key: "aspsicosocial_id", validate: true, optional: false
    belongs_to :respuesta, class_name: "Sivel2Sjr::Respuesta", 
      foreign_key: "respuesta_id", validate: true, optional: false
  end
end
