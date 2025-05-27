# frozen_string_literal: true

module Sivel2Sjr
  # Relación n:n entre Dificultades en la migración y Migración
  class DifmigracionMigracion < ActiveRecord::Base
    self.table_name = "sivel2_sjr_difmigracion_migracion"

    belongs_to :difmigracion,
      class_name: "Sivel2Sjr::Difmigracion",
      optional: false
    belongs_to :migracion,
      class_name: "Sivel2Sjr::Migracion",
      optional: false
  end
end
