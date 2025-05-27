# frozen_string_literal: true

module Sivel2Sjr
  # Tabla básica Roles en familia
  class Rolfamilia < ActiveRecord::Base
    include Msip::Basica

    self.table_name = "sivel2_sjr_rolfamilia"

    has_many :victimasjr,
      class_name: "Sivel2Sjr::Victimasjr",
      validate: true
  end
end
