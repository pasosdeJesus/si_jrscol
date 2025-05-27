# frozen_string_literal: true

# Acto de violencia contra un menor.
class Actonino < ActiveRecord::Base
  include Msip::Modelo
  include Msip::Localizacion
  include Msip::FormatoFechaHelper

  belongs_to :caso,
    validate: true,
    class_name: "Sivel2Gen::Caso",
    optional: false
  belongs_to :ubicacionpre,
    validate: true,
    class_name: "Msip::Ubicacionpre",
    optional: false
  belongs_to :presponsable,
    validate: true,
    class_name: "Sivel2Gen::Presponsable",
    optional: false
  belongs_to :categoria,
    validate: true,
    class_name: "Sivel2Gen::Categoria",
    optional: false
  belongs_to :persona,
    validate: true,
    class_name: "Msip::Persona",
    optional: false

  campofecha_localizado :fecha

  validate :victimas_menores
  def victimas_menores
    if persona && persona.anionac && fecha
      e = Msip::EdadSexoHelper.edad_de_fechanac_fecha(
        persona.anionac,
        persona.mesnac,
        persona.dianac,
        fecha.year,
        fecha.month,
        fecha.day,
      )
      if e > 18
        errors.add(:actonino, "Víctima #{persona.presenta_nombre} es mayor de edad (#{e} años) para la fecha del acto contra menor (#{fecha})")
      elsif e < 0
        errors.add(:actonino, "Víctima #{persona.presenta_nombre} no habría nacido para para la fecha del acto contra menor (#{fecha})")
      end
    end
  end
end
