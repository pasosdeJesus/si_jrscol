module Msip
  class Tipoorgsocial < ActiveRecord::Base
    include Msip::Basica
    has_many :orgsocial, class_name: "Msip::Orgsocial",
      foreign_key: "tipoorgsocial_id", validate: true
  end
end
