module Sivel2Sjr
  # Relación n:n entre Servicios y Asesorias del JRS y Derecho
  class MotivosjrDerecho < ActiveRecord::Base

    self.table_name = "sivel2_sjr_motivosjr_derecho"

    belongs_to :motivosjr, class_name: "Sivel2Sjr::Motivosjr", 
      foreign_key: "motivosjr_id", optional: false
    belongs_to :derecho, class_name: "Sivel2Sjr::Derecho", 
      foreign_key: "derecho_id", optional: false
  end
end
