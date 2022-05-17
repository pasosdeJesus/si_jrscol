require 'sivel2_sjr/concerns/models/caso'
class Sivel2Gen::Caso < ActiveRecord::Base
  include Sivel2Sjr::Concerns::Models::Caso

  has_many :migracion, class_name: 'Sivel2Sjr::Migracion',
    foreign_key: "caso_id", validate: true, dependent: :destroy
  accepts_nested_attributes_for :migracion, allow_destroy: true, 
    reject_if: :all_blank

  # Permitimos casos sin descripción
  def caso_no_vacio
  end

  def presenta(atr)
    case atr.to_s
    when 'fecharec'
      casosjr.fecharec if casosjr.fecharec
    when 'oficina'
      casosjr.oficina.nombre if casosjr.oficina
    when 'asesor'
      casosjr.usuario.nusuario if casosjr.usuario
    when 'contacto'
      if casosjr && casosjr.contacto
        casosjr.contacto.nombres + ' ' + casosjr.contacto.apellidos +
       ' ' + ((casosjr.contacto.tdocumento.nil? ||
               casosjr.contacto.tdocumento.sigla.nil?) ? '' : 
              casosjr.contacto.tdocumento.sigla) + ' ' +
       ' ' + (casosjr.contacto.numerodocumento.nil? ? '' : 
              casosjr.contacto.numerodocumento)
      end
    when 'direccion'
      casosjr.direccion if casosjr.direccion
    when 'telefono'
      casosjr.telefono if casosjr.telefono
    else
      presenta_gen(atr) 
    end
  end

  validate :ppt_y_numero
  def ppt_y_numero
    migracion.each do |m|
      if m.fechasalida.nil?
        errors.add(:migracion, 
                   "En migración debe especificar fecha de salida")
      end
      if m.numppt && m.numppt.length>32 
        errors.add(:migracion, 
                   "Longitud del número ppt no puede exceder 32 caracteres")
      end
      if m.statusmigratorio_id.nil?
        errors.add(:migracion, 
                   "En migración debe especificar estatus migratorio")
      end
      if m.perfilmigracion_id.nil?
        errors.add(:migracion, 
                   "En migración debe especificar perfil de migración")
      end
      if m.pep && (m.numppt.nil? || m.numppt=='')
        errors.add(:migracion, 
                   "Si el migrante tiene PPT debe especificar el número")
      end
    end
  end

end

