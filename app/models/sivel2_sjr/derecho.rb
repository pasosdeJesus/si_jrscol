# frozen_string_literal: true

module Sivel2Sjr
  # Derecho vulnerable
  class Derecho < ActiveRecord::Base
    include Msip::Basica

    self.table_name = "sivel2_sjr_derecho"

    has_and_belongs_to_many :respuesta,
      class_name: "Sivel2Sjr::Respuesta",
      validate: true,
      association_foreign_key: "respuesta_id",
      join_table: "sivel2_sjr_derecho_respuesta"

    has_and_belongs_to_many :ayudaestado,
      class_name: "Sivel2Sjr::Ayudaestado",
      association_foreign_key: "ayudaestado_id",
      join_table: "sivel2_sjr_ayudaestado_derecho"

    has_and_belongs_to_many :ayudasjr,
      class_name: "Sivel2Sjr::Ayudasjr",
      association_foreign_key: "ayudasjr_id",
      join_table: "sivel2_sjr_ayudasjr_derecho"

    has_and_belongs_to_many :motivosjr,
      class_name: "Sivel2Sjr::Motivosjr",
      association_foreign_key: "motivosjr_id",
      join_table: "sivel2_sjr_motivosjr_derecho"

    has_and_belongs_to_many :progestado,
      class_name: "Sivel2Sjr::Progestado",
      association_foreign_key: "progestado_id",
      join_table: "sivel2_sjr_progestado_derecho"

    has_many :ayudaestado_derecho,
      class_name: "Sivel2Sjr::AyudaestadoDerecho"
    has_many :ayudasjr_derecho,
      class_name: "Sivel2Sjr::AyudasjrDerecho"
    has_many :motivosjr_derecho,
      class_name: "Sivel2Sjr::MotivosjrDerecho"
    has_many :progestado_derecho,
      class_name: "Sivel2Sjr::ProgestadoDerecho"
    # has_many :respuesta, :through => :derecho_respuesta
  end
end
