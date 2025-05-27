# frozen_string_literal: true

module Sivel2Sjr
  # Obsoleto
  class AyudasjrRespuesta < ActiveRecord::Base
    self.table_name = "sivel2_sjr_ayudasjr_respuesta"

    belongs_to :ayudasjr,
      class_name: "Sivel2Sjr::Ayudasjr",
      validate: true,
      optional: false
    belongs_to :respuesta,
      class_name: "Sivel2Sjr::Respuesta",
      validate: true,
      optional: false
  end
end
