# frozen_string_literal: true
module Sivel2Sjr
  # Obsoleto
  class AyudaestadoRespuesta < ActiveRecord::Base
    self.table_name = "sivel2_sjr_ayudaestado_respuesta"

    belongs_to :ayudaestado, 
      class_name: "Sivel2Sjr::Ayudaestado", 
      optional: false
    belongs_to :respuesta, 
      class_name: "Sivel2Sjr::Respuesta", 
      optional: false
  end
end
