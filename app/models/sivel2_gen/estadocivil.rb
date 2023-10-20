require 'sivel2_gen/concerns/models/estadocivil'

class Sivel2Gen::Estadocivil < ActiveRecord::Base

  include Sivel2Gen::Concerns::Models::Estadocivil

  has_many :victimasjr, class_name: "Sivel2Sjr::Victimasjr", 
    foreign_key: "estadocivil_id", validate: true

end
