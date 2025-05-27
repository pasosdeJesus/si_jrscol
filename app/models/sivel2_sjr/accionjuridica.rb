# frozen_string_literal: true

module Sivel2Sjr
  # Tabla básica Acciones jurídicas
  class Accionjuridica < ActiveRecord::Base
    include Msip::Basica

    self.table_name = "sivel2_sjr_accionjuridica"

    has_many :accionjuridica_respuesta,
      class_name: "Sivel2Sjr::AccionjuridicaRespuesta"
    has_many :respuesta,
      class_name: "Sivel2Sjr::Respuesta",
      through: :accionjuridica_respuesta
  end
end
