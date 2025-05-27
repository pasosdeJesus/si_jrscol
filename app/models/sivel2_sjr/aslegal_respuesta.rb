# frozen_string_literal: true
module Sivel2Sjr
  # Obsoleto
  class AslegalRespuesta < ActiveRecord::Base
    self.table_name = "sivel2_sjr_aslegal_respuesta"

    belongs_to :aslegal, 
      class_name: "Sivel2Sjr::Aslegal", 
      optional: false
    belongs_to :respuesta, 
      class_name: "Sivel2Sjr::Respuesta", 
      optional: false
  end
end
