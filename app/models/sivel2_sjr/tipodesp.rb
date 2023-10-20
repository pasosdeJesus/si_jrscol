module Sivel2Sjr
  class Tipodesp < ActiveRecord::Base
    include Msip::Basica

    self.table_name = "sivel2_sjr_tipodesp"

    has_many :desplazamiento, class_name: "Sivel2Sjr::Desplazamiento", 
      foreign_key: "tipodesp_id", validate: true
  end
end
