require 'sivel2_sjr/concerns/models/victimasjr'

class Sivel2Sjr::Victimasjr < ActiveRecord::Base
  include Sivel2Sjr::Concerns::Models::Victimasjr

  belongs_to :regimensalud, class_name: "Sivel2Sjr::Regimensalud", 
    foreign_key: "regimensalud_id", validate: true, optional: true
  belongs_to :discapacidad, validate: true, optional: true
end

