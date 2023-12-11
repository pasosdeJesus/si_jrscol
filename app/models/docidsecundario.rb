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

  validates :tdocumento, presence: {
    message: "No puede dejar en blanco el tipo de documento"
  }
  validates :tdocumento, uniqueness: { 
    scope: :persona_id,
    message: "No puede repetir tipo de documento con otro doc. identidad secundario"
  }, allow_blank: false
  validates :numero, presence: {
    message: "No puede dejar en blanco el número de documento"
  }, allow_blank: false, uniqueness: {
    scope: :tdocumento,
    message: "Tipo y número de documento repetido"
  }

  validate :vformatonumdoc
  def vformatonumdoc
    if tdocumento && tdocumento.formatoregex != "" &&
        !(numero =~ Regexp.new("^#{tdocumento.formatoregex}$"))
      menserr = "Número de documento con formato errado."
      if tdocumento.ayuda
        menserr += " #{tdocumento.ayuda}"
      end
      errors.add(:numero, menserr)
    end
  end

  validate :norepetido
  def norepetido
    if !tdocumento_id.nil? && !numero.nil?
      otrosec = Docidsecundario.where(tdocumento_id: tdocumento_id).
        where(numero: numero)
      if otrosec.count > 1 || (otrosec.count == 1 && otrosec.take.id != self.id)
        errors.add(:numero, "Repetido con documento secundario de persona(s): #{otrosec.pluck(:persona_id).join(", ")}")
      end
      otroprin = Msip::Persona.where(tdocumento_id: tdocumento_id).
        where(numerodocumento: numero)
      if otroprin.count >= 1
        errors.add(:numero, "Repetido con documento principal de persona(s): #{otroprin.pluck(:id).join(", ")}")
      end
    end
  end

  validate :tdoc_norepetido_princ
  def tdoc_norepetido_princ
    if !tdocumento_id.nil? && persona.tdocumento_id == tdocumento_id
      errors.add(:tdocumento_id, "No puede repetir tipo de documento con el doc. identidad principal")
    end
  end

end
