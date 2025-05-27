# frozen_string_literal: true

module Sivel2Sjr
  # Tabla básica Servicios y Asesorias del JRS
  class Motivosjr < ActiveRecord::Base
    include Msip::Basica

    self.table_name = "sivel2_sjr_motivosjr"

    has_many :motivosjr_respuesta,
      class_name: "Sivel2Sjr::MotivosjrRespuesta",
      validate: true,
      dependent: :destroy
    has_many :respuesta,
      class_name: "Sivel2Sjr::Respuesta",
      through: :motivosjr_respuesta

    has_many :motivosjr_derecho,
      class_name: "Sivel2Sjr::MotivosjrDerecho",
      validate: true,
      dependent: :destroy
    has_many :derecho,
      class_name: "Sivel2Sjr::Derecho",
      through: :motivosjr_derecho
    accepts_nested_attributes_for :motivosjr_derecho,
      reject_if: :all_blank,
      update_only: true
  end
end
