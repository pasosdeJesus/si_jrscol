# frozen_string_literal: true

module Sivel2Sjr
  # Tabla básica Régimenes salud
  class Regimensalud < ActiveRecord::Base
    include Msip::Basica

    self.table_name = "sivel2_sjr_regimensalud"

    has_many :victimasjr,
      class_name: "Sivel2Sjr::Victimasjr",
      validate: true
  end
end
