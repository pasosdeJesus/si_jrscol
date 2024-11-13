module Sivel2Sjr
  # Tabla básica Necesidades de protección internacional
  class Proteccion < ActiveRecord::Base
    include Msip::Basica

    self.table_name = "sivel2_sjr_proteccion"

    has_many :casosjr, class_name: "Sivel2Sjr::Casosjr", 
      foreign_key: "proteccion_id", validate: true
  end
end
