require 'sivel2_sjr/concerns/models/victima'

class Sivel2Gen::Victima < ActiveRecord::Base

  # Lo ponemos antes del include de Victima para que se ejecute antes
  before_destroy do
    Sivel2Sjr::Actosjr.where("id_acto IN (SELECT id FROM sivel2_gen_acto
                             WHERE id_caso=? AND id_persona=?)", 
                             id_caso, id_persona).delete_all
  end

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
  has_many :msip_anexo, :through => :anexo_victima, 
    class_name: 'Msip::Anexo'
  accepts_nested_attributes_for :msip_anexo,  reject_if: :all_blank

  #validates_associated :persona # Genera un mensaje demasiado simple: 
  # En 'Victima' no es válido 'Persona'

end

