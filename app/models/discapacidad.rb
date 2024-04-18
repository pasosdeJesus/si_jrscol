class Discapacidad < ActiveRecord::Base
  include Msip::Basica

  has_many :persona,
    class_name: 'Msip::Persona',
    validate: true,
    foreign_key: :discapacidad_id

end
