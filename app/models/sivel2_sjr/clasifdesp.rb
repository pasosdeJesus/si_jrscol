# frozen_string_literal: true
module Sivel2Sjr
  # Tabla básica Clasificaciones de Desplazamientos
  class Clasifdesp < ActiveRecord::Base
    include Msip::Basica

    self.table_name = "sivel2_sjr_clasifdesp"

    has_many :desplazamiento, 
      class_name: "Sivel2Sjr::Desplazamiento",
      validate: true
  end
end
