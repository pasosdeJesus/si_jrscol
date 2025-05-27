# frozen_string_literal: true

module Sivel2Sjr
  # Relación n:n entre Causas de la agresión en Colombia y migración
  class CausaagrpaisMigracion < ActiveRecord::Base
    self.table_name = "sivel2_sjr_causaagrpais_migracion"

    belongs_to :causaagrpais,
      class_name: "Sivel2Sjr::Causaagresion",
      optional: false
    belongs_to :migracion,
      class_name: "Sivel2Sjr::Migracion",
      optional: false
  end
end
