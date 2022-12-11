
require 'msip/concerns/models/etiqueta'

module Msip
  class Etiqueta < ActiveRecord::Base
    include Msip::Concerns::Models::Etiqueta

    has_many :etiqueta_persona, class_name: 'Msip::EtiquetaPersona',
      foreign_key: 'etiqueta_id', dependent: :delete_all
    has_many :persona, class_name: 'Msip::Persona',
      through: :etiqueta_persona

  end
end
