require 'sivel2_sjr/concerns/models/oficina'

class Msip::Oficina < ActiveRecord::Base
  include Sivel2Sjr::Concerns::Models::Oficina
  belongs_to :pais, class_name: 'Msip::Pais', foreign_key: 'pais_id', 
    optional: true
  belongs_to :departamento, class_name: 'Msip::Departamento', 
    foreign_key: 'departamento_id', optional: true
  belongs_to :municipio, class_name: 'Msip::Municipio', 
    foreign_key: 'municipio_id', optional: true
  belongs_to :clase, class_name: 'Msip::Clase', foreign_key: 'clase_id', 
    optional: true

end

