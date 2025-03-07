module Sivel2Sjr
  # Datos adicionales de una victima.
  class Victimasjr < ActiveRecord::Base

    include Msip::Modelo

    self.table_name = "sivel2_sjr_victimasjr"

    # Orden de esquema en base
    belongs_to :actividadoficio, 
      class_name: "Sivel2Gen::Actividadoficio", 
      foreign_key: "actividadoficio_id", validate: true, optional: true
    belongs_to :departamento, class_name: "Msip::Departamento", 
      foreign_key: "departamento_id", validate: true, optional: true
    belongs_to :escolaridad, class_name: "Sivel2Gen::Escolaridad", 
      foreign_key: "escolaridad_id", validate: true, optional: true
    belongs_to :estadocivil, class_name: "Sivel2Gen::Estadocivil", 
      foreign_key: "estadocivil_id", validate: true, optional: true
    belongs_to :maternidad, class_name: "Sivel2Gen::Maternidad", 
      foreign_key: "maternidad_id", validate: true, optional: true
    belongs_to :municipio, class_name: "Msip::Municipio", 
      foreign_key: "municipio_id", validate: true, optional: true
    belongs_to :pais, class_name: "Msip::Pais", 
      foreign_key: "pais_id", validate: true, optional: true
    belongs_to :rolfamilia, class_name: "Sivel2Sjr::Rolfamilia", 
      foreign_key: "rolfamilia_id", validate: true, optional: true
    # no validamos :victima porque el controlador crea nuevos 
    # (con persona en nombre vacio y victima no es valido)
    belongs_to :victima, class_name: "Sivel2Gen::Victima", 
      foreign_key: "victima_id", inverse_of: :victimasjr, 
      optional: false

    belongs_to :regimensalud, class_name: "Sivel2Sjr::Regimensalud", 
      foreign_key: "regimensalud_id", validate: true, optional: true
    belongs_to :discapacidad, validate: true, optional: true
  end
end
