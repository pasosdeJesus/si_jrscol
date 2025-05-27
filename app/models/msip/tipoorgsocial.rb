# frozen_string_literal: true

module Msip
  # Tipo de organización social (e.g ASOCIACIÓN O COORPORACIÓN,
  # CANCILLERÍA, EMBAJADA, etc.)
  class Tipoorgsocial < ActiveRecord::Base
    include Msip::Basica
    has_many :orgsocial,
      class_name: "Msip::Orgsocial",
      validate: true
  end
end
