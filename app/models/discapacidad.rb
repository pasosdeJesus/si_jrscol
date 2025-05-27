# frozen_string_literal: true

# Tabla básica Discapacidades
class Discapacidad < ActiveRecord::Base
  include Msip::Basica

  has_many :persona,
    class_name: "Msip::Persona",
    validate: true,
    foreign_key: :ultimadiscapacidad_id
end
