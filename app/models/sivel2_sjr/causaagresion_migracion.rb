# frozen_string_literal: true

module Sivel2Sjr
  # Relación n:n entre Causas de la agresión durante la migración y migración
  class CausaagresionMigracion < ActiveRecord::Base
    self.table_name = "sivel2_sjr_causaagresion_migracion"

    belongs_to :causaagresion,
      class_name: "Sivel2Sjr::Causaagresion",
      optional: false
    belongs_to :migracion,
      class_name: "Sivel2Sjr::Migracion",
      optional: false
  end
end
