
require 'sip/concerns/models/etiqueta'

module Sip
  class Etiqueta < ActiveRecord::Base
    include Sip::Concerns::Models::Etiqueta

    has_many :etiqueta_persona, class_name: 'Sip::EtiquetaPersona',
      foreign_key: 'etiqueta_id', dependent: :delete_all
    has_many :persona, class_name: 'Sip::Persona',
      through: :etiqueta_persona

  end
end
