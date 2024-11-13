module Sivel2Sjr
  # Relación n:n entre Causas de la agresión durante la migración y migración
  class CausaagresionMigracion < ActiveRecord::Base

    self.table_name = "sivel2_sjr_causaagresion_migracion"

    belongs_to :causaagresion,
      class_name: "Sivel2Sjr::Causaagresion",
      foreign_key: "causaagresion_id",
      optional: false
    belongs_to :migracion,
      class_name: "Sivel2Sjr::Migracion",
      foreign_key: "migracion_id",
      optional: false
  end
end
