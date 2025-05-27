# frozen_string_literal: true
# Tabla básica Territorial
class Territorial < ActiveRecord::Base
  include Msip::Basica

  has_many :oficina,
    class_name: "Msip::Oficina",
    validate: true,

  belongs_to :pais,
    class_name: "Msip::Pais",
    optional: true
  belongs_to :departamento,
    class_name: "Msip::Departamento",
    optional: true
  belongs_to :municipio,
    class_name: "Msip::Municipio",
    optional: true
  belongs_to :centropoblado,
    class_name: "Msip::Centropoblado",
    optional: true

end
