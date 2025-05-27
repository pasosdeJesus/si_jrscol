# frozen_string_literal: true

module Sivel2Sjr
  # Relación n:n entre Agresiones durante la migración y Migración
  class AgremigracionMigracion < ActiveRecord::Base
    self.table_name = "sivel2_sjr_agremigracion_migracion"

    belongs_to :agremigracion,
      class_name: "Sivel2Sjr::Agresionmigracion",
      optional: false
    belongs_to :migracion,
      class_name: "Sivel2Sjr::Migracion",
      optional: false
  end
end
