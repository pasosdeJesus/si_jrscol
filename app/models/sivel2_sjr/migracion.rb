# frozen_string_literal: true

require "msip/accesores_ubicacionpre"

module Sivel2Sjr
  # Migración asociado a un caso.
  class Migracion < ActiveRecord::Base
    include Msip::Modelo

    extend Msip::AccesoresUbicacionpre

    self.table_name = "sivel2_sjr_migracion"

    accesores_ubicacionpre :destino

    accesores_ubicacionpre :llegada

    accesores_ubicacionpre :salida

    attr_accessor :tiempoenpais

    # Agregada para evitar validaciones en migraciones eliminadas.
    # Ver https://gitlab.com/pasosdeJesus/si_jrscol/-/issues/799
    attr_accessor :_destroy

    has_and_belongs_to_many :agresionmigracion,
      class_name: "Agresionmigracion",
      association_foreign_key: "agremigracion_id",
      join_table: "sivel2_sjr_agremigracion_migracion"

    has_and_belongs_to_many :agresionenpais,
      class_name: "Agresionmigracion",
      association_foreign_key: "agreenpais_id",
      join_table: "sivel2_sjr_agreenpais_migracion"

    has_and_belongs_to_many :causaagresion,
      class_name: "Causaagresion",
      association_foreign_key: "causaagresion_id",
      join_table: "sivel2_sjr_causaagresion_migracion"

    has_and_belongs_to_many :causaagrpais,
      class_name: "Causaagresion",
      association_foreign_key: "causaagrpais_id",
      join_table: "sivel2_sjr_causaagrpais_migracion"

    has_and_belongs_to_many :dificultadmigracion,
      class_name: "Dificultadmigracion",
      association_foreign_key: "difmigracion_id",
      join_table: "sivel2_sjr_difmigracion_migracion"

    belongs_to :autoridadrefugio,
      class_name: "Autoridadrefugio",
      optional: true
    belongs_to :caso,
      class_name: "Sivel2Gen::Caso",
      optional: false

    belongs_to :causaRefugio,
      class_name: "Sivel2Gen::Categoria",
      optional: true

    belongs_to :viadeingreso,
      class_name: "Viadeingreso",
      optional: true
    belongs_to :causamigracion,
      class_name: "Causamigracion",
      optional: true
    belongs_to :pagoingreso,
      class_name: "Msip::Trivalente",
      optional: true
    belongs_to :miembrofamiliar,
      class_name: "Miembrofamiliar",
      optional: true
    belongs_to :migracontactopre,
      class_name: "::Migracontactopre",
      optional: true

    belongs_to :perfilmigracion,
      class_name: "::Perfilmigracion",
      optional: true

    belongs_to :proteccion,
      class_name: "Sivel2Sjr::Proteccion",
      optional: true

    belongs_to :statusmigratorio,
      class_name: "Sivel2Sjr::Statusmigratorio",
      optional: true
    belongs_to :tipoproteccion,
      class_name: "Tipoproteccion",
      optional: true

    validates :fechasalida, presence: true

    def tiempoenpais
      if id && fechallegada
        fechallegada = self.fechallegada.to_datetime
        hoy = Date.today
        dias = hoy - fechallegada
        return dias.to_i
      end
      ""
    end

    # Agregada para evitar validaciones en migraciones eliminadas.
    # Ver https://gitlab.com/pasosdeJesus/si_jrscol/-/issues/799
    def _destroy
      @destroy
    end

    # Agregada para evitar validaciones en migraciones eliminadas.
    # Ver https://gitlab.com/pasosdeJesus/si_jrscol/-/issues/799
    def _destroy=(val)
      @destroy = val
    end
  end
end
