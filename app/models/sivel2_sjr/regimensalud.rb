module Sivel2Sjr
  class Regimensalud < ActiveRecord::Base
    include Msip::Basica

    has_many :victimasjr, class_name: 'Sivel2Sjr::Victimasjr',
      foreign_key: "id_regimensalud", validate: true
  end
end
