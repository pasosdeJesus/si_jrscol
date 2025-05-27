# frozen_string_literal: true

module Sivel2Sjr
  # Obsoleto
  class OficinaProyectofinanciero < ActiveRecord::Base
    self.table_name = "sivel2_sjr_oficina_proyectofinanciero"

    belongs_to :oficina,
      class_name: "Msip::Oficina",
      optional: false
    belongs_to :proyectofinanciero,
      class_name: "Cor1440Gen::Proyectofinanciero",
      optional: false
  end
end
