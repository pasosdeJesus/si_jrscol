module Sivel2Sjr
  class ProgestadoDerecho < ActiveRecord::Base

    self.table_name = "sivel2_sjr_progestado_derecho"

    belongs_to :progestado, class_name: "Sivel2Sjr::Progestado", 
      foreign_key: "progestado_id", validate: true, optional: false
    belongs_to :derecho, class_name: "Sivel2Sjr::Derecho", 
      foreign_key: "derecho_id", validate: true, optional: false
  end
end
