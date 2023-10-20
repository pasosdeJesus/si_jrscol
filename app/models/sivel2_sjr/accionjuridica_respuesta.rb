module Sivel2Sjr
  class AccionjuridicaRespuesta < ActiveRecord::Base
    include Msip::Modelo

    self.table_name = "sivel2_sjr_accionjuridica_respuesta"

    belongs_to :accionjuridica, class_name: 'Sivel2Sjr::Accionjuridica', 
      foreign_key: "accionjuridica_id", optional: false
    belongs_to :respuesta, class_name: 'Sivel2Sjr::Respuesta',
      foreign_key: "respuesta_id", optional: false

    validates_presence_of :accionjuridica
    validates_presence_of :respuesta

    validates_uniqueness_of :accionjuridica, scope: :respuesta_id
  end
end
