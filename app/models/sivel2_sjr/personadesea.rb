# frozen_string_literal: true

module Sivel2Sjr
  # Tabla básica Beneficiarios desean
  class Personadesea < ActiveRecord::Base
    include Msip::Basica

    self.table_name = "sivel2_sjr_personadesea"

    has_many :respuesta,
      class_name: "Sivel2Sjr::Respuesta",
      foreign_key: "persona_iddesea",
      validate: true
  end
end
