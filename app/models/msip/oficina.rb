require 'msip/concerns/models/oficina'

class Msip::Oficina < ActiveRecord::Base
  include Msip::Concerns::Models::Oficina

  belongs_to :pais, class_name: 'Msip::Pais', foreign_key: 'pais_id', 
    optional: true
  belongs_to :departamento, class_name: 'Msip::Departamento', 
    foreign_key: 'departamento_id', optional: true
  belongs_to :municipio, class_name: 'Msip::Municipio', 
    foreign_key: 'municipio_id', optional: true
  belongs_to :clase, class_name: 'Msip::Clase', foreign_key: 'clase_id', 
    optional: true


  has_many :casosjr, class_name: 'Sivel2Sjr::Casosjr',
    foreign_key: "oficina_id", validate: true

  has_and_belongs_to_many :proyectofinanciero, 
    class_name: 'Cor1440Gen::Proyectofinanciero',
    foreign_key: 'oficina_id', 
    validate: true,
    association_foreign_key: "proyectofinanciero_id",
    join_table: 'sivel2_sjr_oficina_proyectofinanciero'

end

