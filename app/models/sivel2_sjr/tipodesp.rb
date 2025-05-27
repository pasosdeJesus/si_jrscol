# frozen_string_literal: true
module Sivel2Sjr
  # Tabla básica Tipos de desplazamiento
  class Tipodesp < ActiveRecord::Base
    include Msip::Basica

    self.table_name = "sivel2_sjr_tipodesp"

    has_many :desplazamiento, 
      class_name: "Sivel2Sjr::Desplazamiento", 
      validate: true
  end
end
