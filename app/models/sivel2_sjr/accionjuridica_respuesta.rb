# frozen_string_literal: true
module Sivel2Sjr
  # Respuestas usadas hasta 2019 (obsoleto)
  class AccionjuridicaRespuesta < ActiveRecord::Base
    include Msip::Modelo

    self.table_name = "sivel2_sjr_accionjuridica_respuesta"

    belongs_to :accionjuridica, 
      class_name: "Sivel2Sjr::Accionjuridica", 
      optional: false
    belongs_to :respuesta, 
      class_name: "Sivel2Sjr::Respuesta", 
      optional: false

    validates :accionjuridica, presence: true
    validates :respuesta, presence: true

    validates :accionjuridica, uniqueness: { scope: :respuesta_id }
  end
end
