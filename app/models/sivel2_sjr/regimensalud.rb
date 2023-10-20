module Sivel2Sjr
  class Regimensalud < ActiveRecord::Base
    include Msip::Basica

    self.table_name = "sivel2_sjr_regimensalud"

    has_many :victimasjr, class_name: 'Sivel2Sjr::Victimasjr',
      foreign_key: "regimensalud_id", validate: true
  end
end
