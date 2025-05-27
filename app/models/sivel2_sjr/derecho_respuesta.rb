# frozen_string_literal: true
module Sivel2Sjr
  # Obsoleto
  class DerechoRespuesta < ActiveRecord::Base
    self.table_name = "sivel2_sjr_derecho_respuesta"

    belongs_to :derecho, 
      class_name: "Sivel2Sjr::Derecho",
      validate: true, 
      optional: false
    belongs_to :respuesta, 
      class_name: "Sivel2Sjr::Respuesta", 
      validate: true, 
      optional: false
  end
end
