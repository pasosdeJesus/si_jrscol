module Sivel2Sjr
  class Clasifdesp < ActiveRecord::Base
    include Msip::Basica

    self.table_name = "sivel2_sjr_clasifdesp"

    has_many :desplazamiento, class_name: "Sivel2Sjr::Desplazamiento", 
      foreign_key: "clasifdesp_id", validate: true
  end
end
