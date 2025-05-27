# frozen_string_literal: true
module Sivel2Sjr
  # Datos adicionales de una victima.
  class Victimasjr < ActiveRecord::Base
    include Msip::Modelo

    self.table_name = "sivel2_sjr_victimasjr"

    # Orden de esquema en base
    belongs_to :actividadoficio,
      class_name: "Sivel2Gen::Actividadoficio", 
      validate: true, 
      optional: true
    belongs_to :departamento, 
      class_name: "Msip::Departamento", 
      validate: true, 
      optional: true
    belongs_to :escolaridad, 
      class_name: "Sivel2Gen::Escolaridad", 
      validate: true, 
      optional: true
    belongs_to :estadocivil, 
      class_name: "Sivel2Gen::Estadocivil", 
      validate: true, 
      optional: true
    belongs_to :maternidad, 
      class_name: "Sivel2Gen::Maternidad", 
      validate: true, 
      optional: true
    belongs_to :municipio, 
      class_name: "Msip::Municipio", 
      validate: true, 
      optional: true
    belongs_to :pais, 
      class_name: "Msip::Pais", 
      validate: true, 
      optional: true
    belongs_to :rolfamilia, 
      class_name: "Sivel2Sjr::Rolfamilia", 
      validate: true, 
      optional: true
    # no validamos :victima porque el controlador crea nuevos
    # (con persona en nombre vacio y victima no es valido)
    belongs_to :victima, 
      class_name: "Sivel2Gen::Victima", 
      inverse_of: :victimasjr,
      optional: false

    belongs_to :regimensalud, 
      class_name: "Sivel2Sjr::Regimensalud", 
      validate: true, 
      optional: true
    belongs_to :discapacidad, validate: true, optional: true
  end
end
