# frozen_string_literal: true
module Sivel2Sjr
  # Tabla básica Acreditaciones (de desplazamiento)
  class Acreditacion < ActiveRecord::Base
    include Msip::Basica

    self.table_name = "sivel2_sjr_acreditacion"

    has_many :desplazamiento, 
      class_name: "Sivel2Sjr::Desplazamiento",
      validate: true
  end
end
