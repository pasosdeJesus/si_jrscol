# frozen_string_literal: true
module Sivel2Sjr
  # Obsoleto
  class AspsicosocialRespuesta < ActiveRecord::Base
    self.table_name = "sivel2_sjr_aspsicosocial_respuesta"

    belongs_to :aspsicosocial, 
      class_name: "Sivel2Sjr::Aspsicosocial", 
      validate: true, 
      optional: false
    belongs_to :respuesta, 
      class_name: "Sivel2Sjr::Respuesta", 
      validate: true, 
      optional: false
  end
end
