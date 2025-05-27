# frozen_string_literal: true
require "msip/accesores_ubicacionpre"

module Sivel2Sjr
  # Desplazamiento asociado a un caso
  class Desplazamiento < ActiveRecord::Base
    extend Msip::AccesoresUbicacionpre

    include Msip::Modelo

    self.table_name = "sivel2_sjr_desplazamiento"

    has_many :actosjr, 
      class_name: "Sivel2Sjr::Actosjr",
      validate: true
    accesores_ubicacionpre :destino

    accesores_ubicacionpre :llegada

    accesores_ubicacionpre :expulsion

    has_and_belongs_to_many :categoria,
      class_name: "Sivel2Gen::Categoria",
      association_foreign_key: "categoria_id",
      join_table: "sivel2_sjr_categoria_desplazamiento"

    belongs_to :declaracionruv,
      class_name: "Declaracionruv",
      optional: true

    validates :tipodesp, presence: true

    belongs_to :clasifdesp, 
      class_name: "Sivel2Sjr::Clasifdesp", 
      validate: true, 
      optional: true
    belongs_to :tipodesp, 
      class_name: "Sivel2Sjr::Tipodesp", 
      validate: true, 
      optional: true
    belongs_to :declaroante, 
      class_name: "Sivel2Sjr::Declaroante", 
      validate: true, 
      optional: true
    belongs_to :inclusion, 
      class_name: "Sivel2Sjr::Inclusion", 
      validate: true, 
      optional: true
    belongs_to :acreditacion,
      class_name: "Sivel2Sjr::Acreditacion", 
      validate: true, 
      optional: true
    belongs_to :modalidadtierra,
      class_name: "Sivel2Sjr::Modalidadtierra", 
      validate: true, 
      optional: true
    belongs_to :pais, 
      class_name: "Msip::Pais",
      foreign_key: "paisdecl", 
      validate: true, 
      optional: true
    belongs_to :departamento, 
      class_name: "Msip::Departamento",
      foreign_key: "departamentodecl", 
      validate: true, 
      optional: true
    belongs_to :municipio, 
      class_name: "Msip::Municipio",
      foreign_key: "municipiodecl", 
      validate: true, 
      optional: true
    belongs_to :caso, 
      class_name: "Sivel2Gen::Caso", 
      validate: true, 
      optional: false

    validates :fechaexpulsion, :fechallegada, presence: true
    validates :fechaexpulsion, uniqueness:
      { 
        scope: :caso_id,
        message: " ya existe otro desplazamiento " \
        "con la misma fecha de expulsión",}

    validate :llegada_posterior_a_expulsion
    def llegada_posterior_a_expulsion
      if fechallegada.present? &&
          fechaexpulsion.present? && fechallegada < fechaexpulsion
        errors.add(
          :fechallegada,
          " debe ser posterior a la fecha de expulsión")
      end
    end

    validate :fechaexpulsion_unica
    def fechaexpulsion_unica
      if fechaexpulsion.present? &&
          Sivel2Sjr::Desplazamiento.where(
            caso_id: caso_id,
            fechaexpulsion: fechaexpulsion).count > 1
        errors.add(:fechaexpulsion, " debe ser única")
      end
    end

    validate :sitios_diferentes
    def sitios_diferentes
      if llegada.present? && expulsion.present? &&
          llegadaubicacionpre_id == expulsionubicacionpre_id
        errors.add(
          :llegada,
          " debe ser diferente al sitio de expulsion")
      end
    end
  end
end
