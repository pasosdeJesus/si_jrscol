# frozen_string_literal: true

module Sivel2Sjr
  # Relación n:n entre Ayuda del JRS y Derecho que suple
  class AyudasjrDerecho < ActiveRecord::Base
    self.table_name = "sivel2_sjr_ayudasjr_derecho"

    belongs_to :ayudasjr,
      class_name: "Sivel2Sjr::Ayudasjr",
      validate: true,
      optional: true
    belongs_to :derecho,
      class_name: "Sivel2Sjr::Derecho",
      validate: true,
      optional: true
  end
end
