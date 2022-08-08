
require 'sip/concerns/models/etiqueta'

module Sip
  class Etiqueta < ActiveRecord::Base
    include Sip::Concerns::Models::Etiqueta

    has_many :etiqueta_persona, class_name: 'Sivel2Gen::EtiquetaPersona',
      foreign_key: 'id_etiqueta', dependent: :delete_all
    has_many :persona, class_name: 'Sivel2Gen::Persona',
      through: :etiqueta_persona

  end
end
