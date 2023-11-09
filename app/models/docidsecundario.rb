class Docidsecundario < ActiveRecord::Base

  include Msip::Modelo
  include Msip::Localizacion
  include Msip::FormatoFechaHelper

  belongs_to :persona,
    foreign_key: 'persona_id',
    validate: true,
    class_name: 'Msip::Persona', 
    optional: false
  belongs_to :tdocumento,
    foreign_key: 'tdocumento_id',
    validate: true,
    class_name: 'Msip::Tdocumento', 
    optional: false

  validates :numero, presence: true
end
