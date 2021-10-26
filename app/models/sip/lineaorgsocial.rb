module Sip
  class Lineaorgsocial < ActiveRecord::Base
    include Sip::Basica
    has_many :orgsocial, class_name: "Sip::Orgsocial",
      foreign_key: "lineaorgsocial_id", validate: true 
  end
end
