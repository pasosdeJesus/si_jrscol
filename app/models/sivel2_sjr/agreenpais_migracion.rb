module Sivel2Sjr
  # Relación n:n entre Agresiones durante la migración en Colombia y Migración
  class AgreenpaisMigracion < ActiveRecord::Base

    self.table_name = "sivel2_sjr_agreenpais_migracion"

    belongs_to :agreenpais,
      class_name: "Sivel2Sjr::Agresionmigracion",
      foreign_key: "agreenpais_id",
      optional: false
    belongs_to :migracion,
      class_name: "Sivel2Sjr::Migracion",
      foreign_key: "migracion_id",
      optional: false
  end
end
