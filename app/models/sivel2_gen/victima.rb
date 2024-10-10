require 'sivel2_gen/concerns/models/victima'

module Sivel2Gen
  # Integrante de un grupo familiar en un caso. 
  class Victima < ActiveRecord::Base

    # Lo ponemos antes del include de Victima para que se ejecute antes
    before_destroy do
      Sivel2Sjr::Actosjr.where("acto_id IN (SELECT id FROM sivel2_gen_acto
                             WHERE caso_id=? AND persona_id=?)", 
                             caso_id, persona_id).delete_all
    end

    include Sivel2Gen::Concerns::Models::Victima

    #has_many :antecedente_victima, foreign_key: :victima_id, 
    #  validate: true, dependent: :destroy

    has_one :victimasjr, class_name: 'Sivel2Sjr::Victimasjr', 
      foreign_key: "victima_id", dependent: :destroy, validate: true, 
      inverse_of: :victima
    accepts_nested_attributes_for :victimasjr, reject_if: :all_blank,
      update_only: true

    attr_accessor :rangoedadactual_id
    belongs_to :rangoedadactual, foreign_key: "rangoedadactual_id", 
      validate: true, class_name: "Sivel2Gen::Rangoedad", optional: true

    has_many :anexo_victima, foreign_key: 'victima_id', 
      validate: true, dependent: :destroy, 
      class_name: 'Sivel2Gen::AnexoVictima',
      inverse_of: :victima
    accepts_nested_attributes_for :anexo_victima, allow_destroy: true, 
      reject_if: :all_blank
    has_many :msip_anexo, :through => :anexo_victima, 
      class_name: 'Msip::Anexo'
    accepts_nested_attributes_for :msip_anexo,  reject_if: :all_blank

    #validates_associated :persona # Genera un mensaje demasiado simple: 
    # En 'Victima' no es válido 'Persona'

  end
end
