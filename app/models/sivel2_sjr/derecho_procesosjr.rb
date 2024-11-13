module Sivel2Sjr
  # Obsoleto
  class DerechoProcesosjr < ActiveRecord::Base

    self.table_name = "sivel2_sjr_derecho_procesosjr"

    belongs_to :procesosjr, class_name: "Sivel2Sjr::Procesosjr",
      foreign_key: "id_proceso", validate: true, optional: false
    belongs_to :derecho, class_name: "Sivel2Sjr::Derecho", 
      foreign_key: "derecho_id", validate: true, optional: false
  end
end
