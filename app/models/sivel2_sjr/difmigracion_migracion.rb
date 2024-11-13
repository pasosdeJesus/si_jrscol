module Sivel2Sjr
  # Relación n:n entre Dificultades en la migración y Migración
  class DifmigracionMigracion < ActiveRecord::Base

    self.table_name = "sivel2_sjr_difmigracion_migracion"

    belongs_to :difmigracion,
      class_name: "Sivel2Sjr::Difmigracion",
      foreign_key: "difmigracion_id",
      optional: false
    belongs_to :migracion,
      class_name: "Sivel2Sjr::Migracion",
      foreign_key: "migracion_id",
      optional: false
  end
end
