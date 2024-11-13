module Sivel2Sjr
  # Tabla básica Asesorías jurídicas
  class Aslegal < ActiveRecord::Base
    include Msip::Basica

    self.table_name = "sivel2_sjr_aslegal"

    has_and_belongs_to_many :respuesta, 
      class_name: "Sivel2Sjr::Respuesta",
      foreign_key: "aslegal_id", 
      validate: true, 
      association_foreign_key: "respuesta_id",
      join_table: 'sivel2_sjr_aslegal_respuesta' 

  end
end
