# encoding: UTF-8
require 'sivel2_sjr/concerns/models/victima'

class Sivel2Gen::Victima < ActiveRecord::Base
  include Sivel2Sjr::Concerns::Models::Victima

  attr_accessor :rangoedadactual_id
  belongs_to :rangoedadactual, foreign_key: "rangoedadactual_id", 
    validate: true, class_name: "Sivel2Gen::Rangoedad", optional: true

  has_many :anexo_victima, foreign_key: 'victima_id', 
    validate: true, dependent: :destroy, 
    class_name: 'Sivel2Gen::AnexoVictima',
    inverse_of: :victima
  accepts_nested_attributes_for :anexo_victima, allow_destroy: true, 
    reject_if: :all_blank
  has_many :sip_anexo, :through => :anexo_victima, 
    class_name: 'Sip::Anexo'
  accepts_nested_attributes_for :sip_anexo,  reject_if: :all_blank

  #validates_associated :persona # Genera un mensaje demasiado simple: 
  # En 'Victima' no es válido 'Persona'

  validate :persona_valida

  def persona_valida
    if !persona || !persona.valid?
      persona.errors.full_messages.each do |e|
        if !errors.full_messages.include?(e)
          errors.add("persona_#{persona.id}".to_sym, e)
        end
      end
    end
  end
end

