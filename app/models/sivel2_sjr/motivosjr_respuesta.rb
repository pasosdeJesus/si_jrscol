# frozen_string_literal: true
module Sivel2Sjr
  # Obsoleto
  class MotivosjrRespuesta < ActiveRecord::Base
    self.table_name = "sivel2_sjr_motivosjr_respuesta"

    belongs_to :motivosjr, 
class_name: "Sivel2Sjr::Motivosjr",, 
validate: true, 
optional: false
    belongs_to :respuesta, 
class_name: "Sivel2Sjr::Respuesta",, 
validate: true, 
optional: false
  end
end
