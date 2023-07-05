require 'sivel2_gen/concerns/models/caso'
class Sivel2Gen::Caso < ActiveRecord::Base
  include Sivel2Gen::Concerns::Models::Caso

  has_many :actosjr, class_name: 'Sivel2Sjr::Actosjr',
    :through => :acto, dependent: :destroy
  accepts_nested_attributes_for :actosjr, allow_destroy: true, 
    reject_if: :all_blank

  has_one :casosjr, class_name: 'Sivel2Sjr::Casosjr',
    foreign_key: "caso_id", inverse_of: :caso, validate: true, 
    dependent: :destroy
  accepts_nested_attributes_for :casosjr, allow_destroy: true, 
    update_only: true

  # respuesta deberìa ser con :through => :casosjr pero más dificil guardar
  has_many :respuesta, class_name: 'Sivel2Sjr::Respuesta',
    foreign_key: "caso_id", validate:true, dependent: :destroy
  accepts_nested_attributes_for :respuesta, allow_destroy: true, 
    reject_if: :all_blank

  has_many :desplazamiento, class_name: 'Sivel2Sjr::Desplazamiento',
    foreign_key: "caso_id", validate: true, dependent: :destroy
  accepts_nested_attributes_for :desplazamiento , allow_destroy: true, 
    reject_if: :all_blank
  has_many :victimasjr, class_name: 'Sivel2Sjr::Victimasjr',
    :through => :victima, dependent: :destroy
  accepts_nested_attributes_for :victimasjr, allow_destroy: true, 
    reject_if: :all_blank

  has_many :migracion, class_name: 'Sivel2Sjr::Migracion',
    foreign_key: "caso_id", validate: true, dependent: :destroy
  accepts_nested_attributes_for :migracion, allow_destroy: true, 
    reject_if: :all_blank


  validate :beneficiarios_con_ultimoperfilorgsocial
  def beneficiarios_con_ultimoperfilorgsocial
    victima.each do |v|
      if v.persona.ultimoperfilorgsocial_id.nil?
        errors.add(:persona, "Falta perfil poblacional de #{v.persona.presenta_nombre}")
      end
      if [10, 11, 12].include?(v.persona.ultimoperfilorgsocial_id) && 
          v.persona.ultimoestatusmigratorio_id.nil?
        errors.add(:persona, "Falta estatus migratorio de #{v.persona.presenta_nombre}")
      end

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
      if !m._destroy && m.statusmigratorio_id.nil?
        errors.add(:migracion, 
                   "En migración debe especificar estatus migratorio")
      end
      if !m._destroy && m.perfilmigracion_id.nil?
        errors.add(:migracion, 
                   "En migración debe especificar perfil de migración")
      end
      if m.pep && (m.numppt.nil? || m.numppt=='')
        errors.add(:migracion, 
                   "Si el migrante tiene PPT debe especificar el número")
      end
    end
  end


  def presenta(atr)
    case atr.to_s
    when 'fecharec'
      casosjr.fecharec if casosjr && casosjr.fecharec
    when 'oficina'
      casosjr.oficina.nombre if casosjr && casosjr.oficina
    when 'asesor'
      casosjr.usuario.nusuario if casosjr && casosjr.usuario
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
      casosjr.direccion if casosjr && casosjr.direccion
    when 'telefono'
      casosjr.telefono if casosjr && casosjr.telefono
    else
      presenta_gen(atr) 
    end
  end


end

