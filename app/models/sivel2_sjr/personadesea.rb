module Sivel2Sjr
  class Personadesea < ActiveRecord::Base
    include Msip::Basica

    self.table_name = "sivel2_sjr_personadesea"

    has_many :respuesta, class_name: "Sivel2Sjr::Respuesta", 
      foreign_key: "persona_iddesea", validate: true
  end
end
