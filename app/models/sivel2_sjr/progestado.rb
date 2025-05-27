# frozen_string_literal: true

module Sivel2Sjr
  # Tabla básica Programas del estado.
  class Progestado < ActiveRecord::Base
    include Msip::Basica

    self.table_name = "sivel2_sjr_progestado"

    has_many :progestado_respuesta,
      class_name: "Sivel2Sjr::ProgestadoRespuesta",
      validate: true,
      dependent: :destroy
    has_many :respuesta,
      class_name: "Sivel2Sjr::Respuesta",
      through: :progestado_respuesta

    has_many :progestado_derecho,
      class_name: "Sivel2Sjr::ProgestadoDerecho",
      validate: true,
      dependent: :destroy
    has_many :derecho,
      class_name: "Sivel2Sjr::Derecho",
      through: :progestado_derecho
    accepts_nested_attributes_for :progestado_derecho,
      reject_if: :all_blank,
      update_only: true
  end
end
