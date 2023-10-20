module Sivel2Sjr
  class Modalidadtierra < ActiveRecord::Base
    include Msip::Basica

    self.table_name = "sivel2_sjr_modalidadtierra"

    has_many :desplazamiento, class_name: "Sivel2Sjr::Desplazamiento", 
      foreign_key: "modalidadtierra_id", validate: true
  end
end
