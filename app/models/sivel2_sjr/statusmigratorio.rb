class Sivel2Sjr::Statusmigratorio < ActiveRecord::Base

  include Msip::Basica

  has_many :casosjr, class_name: "Sivel2Sjr::Casosjr", 
    foreign_key: "estatusmigratorio_id", validate: true

end
