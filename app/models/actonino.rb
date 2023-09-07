class Actonino < ActiveRecord::Base

  include Msip::Modelo
  include Msip::Localizacion
  include Msip::FormatoFechaHelper

  belongs_to :caso,
    foreign_key: 'caso_id',
    validate: true,
    class_name: 'Sivel2Gen::Caso', 
    optional: false
  belongs_to :ubicacionpre,
    foreign_key: 'ubicacionpre_id',
    validate: true,
    class_name: 'Msip::Ubicacionpre', 
    optional: false
  belongs_to :presponsable,
    foreign_key: 'presponsable_id',
    validate: true,
    class_name: 'Sivel2Gen::Presponsable', 
    optional: false
  belongs_to :categoria,
    foreign_key: 'categoria_id',
    validate: true,
    class_name: 'Sivel2Gen::Categoria', 
    optional: false
  belongs_to :persona,
    foreign_key: 'persona_id',
    validate: true,
    class_name: 'Msip::Persona', 
    optional: false

  campofecha_localizado :fecha

  validate :victimas_menores
  def victimas_menores
    if persona && persona.anionac && fecha
      e = Msip::EdadSexoHelper.edad_de_fechanac_fecha(
        persona.anionac, persona.mesnac, persona.dianac,
        fecha.year, fecha.month, fecha.day)
      if (e>18) then
          errors.add(:actonino, "Víctima #{persona.presenta_nombre} es mayor de edad (#{e} años) para la fecha del acto contra menor (#{self.fecha})")
      end
    end
  end

end
