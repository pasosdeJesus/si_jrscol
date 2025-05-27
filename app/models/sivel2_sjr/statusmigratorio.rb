# frozen_string_literal: true

module Sivel2Sjr
  # Tabla básica estatus migratorio
  class Statusmigratorio < ActiveRecord::Base
    include Msip::Basica

    self.table_name = "sivel2_sjr_statusmigratorio"

    has_many :casosjr,
      class_name: "Sivel2Sjr::Casosjr",
      foreign_key: "estatusmigratorio_id",
      validate: true
  end
end
