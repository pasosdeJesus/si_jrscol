# frozen_string_literal: true

require "sivel2_gen/concerns/models/anexo"

module Msip
  # Tipo de anexo (e.g CONSENTIMIENTO DATOS, ANEXO DE VÍCTIMA, OTROS)
  class Tipoanexo < ActiveRecord::Base
    include Msip::Basica

    has_many :anexo_victima,
      validate: true,
      class_name: "Sivel2Gen::AnexoVictima"
    has_many :victima,
      class_name: "Sivel2Gen::Victima",
      through: :anexo_victima
  end
end
