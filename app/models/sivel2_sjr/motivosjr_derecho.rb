# frozen_string_literal: true
module Sivel2Sjr
  # Relación n:n entre Servicios y Asesorias del JRS y Derecho
  class MotivosjrDerecho < ActiveRecord::Base
    self.table_name = "sivel2_sjr_motivosjr_derecho"

    belongs_to :motivosjr, 
class_name: "Sivel2Sjr::Motivosjr",, 
optional: false
    belongs_to :derecho, 
class_name: "Sivel2Sjr::Derecho",, 
optional: false
  end
end
