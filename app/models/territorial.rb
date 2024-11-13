# Tabla básica Territorial
class Territorial < ActiveRecord::Base
  include Msip::Basica

  has_many :oficina,
    class_name: 'Msip::Oficina',
    validate: true, 
    foreign_key: :territorial_id

  belongs_to :pais,
    class_name: 'Msip::Pais',
    foreign_key: :pais_id,
    optional: true
  belongs_to :departamento,
    class_name: 'Msip::Departamento',
    foreign_key: :departamento_id,
    optional: true
  belongs_to :municipio,
    class_name: 'Msip::Municipio',
    foreign_key: :municipio_id,
    optional: true
  belongs_to :centropoblado,
    class_name: 'Msip::Centropoblado',
    foreign_key: :centropoblado_id,
    optional: true


end
