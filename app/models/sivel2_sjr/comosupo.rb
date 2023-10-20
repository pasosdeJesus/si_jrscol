module Sivel2Sjr
  class Comosupo < ActiveRecord::Base
    include Msip::Basica

    self.table_name = "sivel2_sjr_comosupo"

    has_many :casosjr, class_name: "Sivel2Sjr::Casosjr"
  end
end
