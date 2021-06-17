# encoding: UTF-8

module Sip
  class Tipoorgsocial < ActiveRecord::Base
    include Sip::Basica
    has_many :orgsocial, class_name: "Sip::Orgsocial",
      foreign_key: "tipoorgsocial_id", validate: true
  end
end
