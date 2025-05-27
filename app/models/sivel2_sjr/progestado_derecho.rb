# frozen_string_literal: true
module Sivel2Sjr
  # Relación n:n entre Programas del Estado y Derechos
  class ProgestadoDerecho < ActiveRecord::Base
    self.table_name = "sivel2_sjr_progestado_derecho"

    belongs_to :progestado, 
class_name: "Sivel2Sjr::Progestado",, 
validate: true, 
optional: false
    belongs_to :derecho, 
class_name: "Sivel2Sjr::Derecho",, 
validate: true, 
optional: false
  end
end
