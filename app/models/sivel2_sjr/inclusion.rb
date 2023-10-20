module Sivel2Sjr
  class Inclusion < ActiveRecord::Base
    include Msip::Basica

    self.table_name = "sivel2_sjr_inclusion"

    has_many :desplazamiento, class_name: "Sivel2Sjr::Desplazamiento", 
      foreign_key: "inclusion_id", validate: true
  end
end
