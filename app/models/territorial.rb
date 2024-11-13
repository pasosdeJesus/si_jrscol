# Tabla básica Territorial
class Territorial < ActiveRecord::Base
  include Msip::Basica

  has_many :oficina,
    class_name: 'Msip::Oficina',
    validate: true, 
    foreign_key: :territorial_id

end
