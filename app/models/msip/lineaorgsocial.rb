# frozen_string_literal: true

module Msip
  # Línea de una organización social, e.g. MEDIO AMBIENTE, GÉNERO, DDHH, etc.
  class Lineaorgsocial < ActiveRecord::Base
    include Msip::Basica
    has_many :orgsocial,
      class_name: "Msip::Orgsocial",
      validate: true
  end
end
