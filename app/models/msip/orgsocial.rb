# frozen_string_literal: true

require "cor1440_gen/concerns/models/orgsocial"

module Msip
  class Orgsocial < ActiveRecord::Base
    include Cor1440Gen::Concerns::Models::Orgsocial
    belongs_to :departamento,
      class_name: "Msip::Departamento",
      validate: true,
      optional: true
    belongs_to :lineaorgsocial,
      class_name: "Msip::Lineaorgsocial",
      validate: true,
      optional: true
    belongs_to :municipio,
      class_name: "Msip::Municipio",
      validate: true,
      optional: true
    belongs_to :tipoorgsocial,
      class_name: "Msip::Tipoorgsocial",
      validate: true,
      optional: true

    validates :tipoorgsocial_id, presence: true
    validates :nit, uniqueness: true, allow_blank: true

    def presenta(atr)
      case atr.to_s
      when "actualización"
        presenta_cor1440_gen("updated_at")
      when "creación"
        presenta_cor1440_gen("created_at")
      when "dirección"
        direccion ? direccion : ""
      when "país"
        pais ? pais.nombre : ""
      when "población_relacionada"
        presenta_cor1440_gen("sectores")
      when "teléfono"
        telefono ? telefono : ""
      when "tipo"
        tipoorgsocial ? tipoorgsocial.nombre : ""
      else
        presenta_cor1440_gen(atr)
      end
    end
  end
end
