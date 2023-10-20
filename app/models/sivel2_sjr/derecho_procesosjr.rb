module Sivel2Sjr
  class DerechoProcesosjr < ActiveRecord::Base

    self.table_name = "sivel2_sjr_derecho_procesosjr"

    foreign_key: "id_proceso", validate: true, optional: false
    belongs_to :derecho, class_name: "Sivel2Sjr::Derecho", 
      foreign_key: "derecho_id", validate: true, optional: false
  end
end
