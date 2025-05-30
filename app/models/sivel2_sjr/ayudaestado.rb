# frozen_string_literal: true

module Sivel2Sjr
  # Tabla básicas Ayudas del Estado
  class Ayudaestado < ActiveRecord::Base
    include Msip::Basica

    self.table_name = "sivel2_sjr_ayudaestado"

    has_many :ayudaestado_respuesta,
      class_name: "Sivel2Sjr::AyudaestadoRespuesta",
      validate: true,
      dependent: :destroy
    has_many :respuesta,
      class_name: "Sivel2Sjr::Respuesta",
      through: :ayudaestado_respuesta

    has_many :ayudaestado_derecho,
      class_name: "Sivel2Sjr::AyudaestadoDerecho",
      validate: true,
      dependent: :destroy
    has_many :derecho,
      class_name: "Sivel2Sjr::Derecho",
      through: :ayudaestado_derecho
    accepts_nested_attributes_for :ayudaestado_derecho,
      reject_if: :all_blank,
      update_only: true
  end
end
