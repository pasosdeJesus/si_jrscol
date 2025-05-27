# frozen_string_literal: true
module Sivel2Sjr
  # Relación n:n entre Ayudas del Estado y Derecho que suplen
  class AyudaestadoDerecho < ActiveRecord::Base
    self.table_name = "sivel2_sjr_ayudaestado_derecho"

    belongs_to :ayudaestado,
      class_name: "Sivel2Sjr::Ayudaestado",
      validate: true,
      optional: false
    belongs_to :derecho,
      class_name: "Sivel2Sjr::Derecho",
      validate: true,
      optional: false
  end
end
