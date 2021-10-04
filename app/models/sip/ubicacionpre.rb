require 'sip/concerns/models/ubicacionpre'

module Sip
  class Ubicacionpre < ActiveRecord::Base
    include Sip::Concerns::Models::Ubicacionpre

    has_many :expulsion, class_name: "Sivel2Sjr::Desplazamiento", 
      foreign_key: "expulsionubicacionpre_id", validate: true, 
      dependent: :destroy
    has_many :llegada, class_name: "Sivel2Sjr::Desplazamiento", 
      foreign_key: "llegadaubicacionpre_id", validate: true, 
      dependent: :destroy

    attr_accessor :id_pais

    def id_pais
      self.pais_id
    end

    def id_departamento
      self.departamento_id
    end

    def id_municipio
      self.municipio_id
    end

    def id_clase
      self.clase_id
    end

  end
end
