# frozen_string_literal: true
module Sivel2Sjr
  # Obsoleto
  class ProgestadoRespuesta < ActiveRecord::Base
    self.table_name = "sivel2_sjr_progestado_respuesta"

    belongs_to :progestado, 
class_name: "Sivel2Sjr::Progestado",, 
validate: true, 
optional: false
    belongs_to :respuesta, 
class_name: "Sivel2Sjr::Rrespuesta",, 
validate: true, 
optional: false
  end
end
