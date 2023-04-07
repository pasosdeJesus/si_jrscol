require 'msip/concerns/models/ubicacionpre'

module Msip
  class Ubicacionpre < ActiveRecord::Base
    include Msip::Concerns::Models::Ubicacionpre

    has_many :expulsion, class_name: "Sivel2Sjr::Desplazamiento", 
      foreign_key: "expulsionubicacionpre_id", validate: true, 
      dependent: :destroy
    has_many :llegada, class_name: "Sivel2Sjr::Desplazamiento", 
      foreign_key: "llegadaubicacionpre_id", validate: true, 
      dependent: :destroy

#    attr_accessor :pais_id

#    def pais_id
#      self.pais_id
#    end

#    def departamento_id
#      self.departamento_id
#    end

#    def municipio_id
#      self.municipio_id
#    end

#    def clase_id
#      self.clase_id
#    end

  end
end
