# frozen_string_literal: true

# Tabla básica Indicadores GIFMM
class Indicadorgifmm < ActiveRecord::Base
  include Msip::Basica

  belongs_to :sectorgifmm,
    validate: true,
    class_name: "Sectorgifmm",
    optional: false

  has_many :actividadpf,
    class_name: "Cor1440Gen::Actividadpf"
end
