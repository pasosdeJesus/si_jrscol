# frozen_string_literal: true

module Sivel2Sjr
  # Tabla básica Declaro Ante
  class Declaroante < ActiveRecord::Base
    include Msip::Basica

    self.table_name = "sivel2_sjr_declaroante"

    has_many :desplazamiento,
      class_name: "Sivel2Sjr::Desplazamiento",
      validate: true
  end
end
