module Sivel2Sjr
  class MotivosjrDerecho < ActiveRecord::Base

    self.table_name = "sivel2_sjr_motivosjr_derecho"

    belongs_to :motivosjr, class_name: "Sivel2Sjr::Motivosjr", 
      foreign_key: "motivosjr_id", optional: false
    belongs_to :derecho, class_name: "Sivel2Sjr::Derecho", 
      foreign_key: "derecho_id", optional: false
  end
end
