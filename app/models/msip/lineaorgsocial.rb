module Msip
  class Lineaorgsocial < ActiveRecord::Base
    include Msip::Basica
    has_many :orgsocial, class_name: "Msip::Orgsocial",
      foreign_key: "lineaorgsocial_id", validate: true 
  end
end
