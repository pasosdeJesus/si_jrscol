require 'sivel2_sjr/concerns/models/casosjr'

class Sivel2Sjr::Casosjr < ActiveRecord::Base
  include Sivel2Sjr::Concerns::Models::Casosjr

  belongs_to :llegadam, class_name: 'Msip::Ubicacion', validate: true,
    foreign_key: 'id_llegadam', optional: true
  belongs_to :salidam, class_name: 'Msip::Ubicacion', validate: true,
    foreign_key: 'id_salidam', optional: true

  has_many :asesorhistorico,
    class_name: '::Asesorhistorico',
    validate: true, 
    foreign_key: :casosjr_id

  validates :motivom, length: { maximum: 5000 }
  validates :memo1612, length: { maximum: 5000 }
  validates :contacto, uniqueness: { 
    message: 'Contacto no puede estar repetido en dos casos' 
  }

  validates :estatus_refugio, length: { maximum: 5000 }
  validates :docrefugiado, length: { maximum: 128 }

  validate :sitiosm_diferentes
  def sitiosm_diferentes
    if llegadam.present? && salidam.present? && id_llegadam == id_salidam
      errors.add(:llegadam, " debe ser diferente al sitio de salida en migración")
    end
  end

  validate :fecharec_pasada
  def fecharec_pasada
    if fecharec && fecharec>Date.today
      errors.add(:fecharec, 
                 " la fecha de recepción debe ser en el pasado")
    end
  end

  validate :llegadam_posterior_a_salida
  def llegadam_posterior_a_salida
    if fechallegadam.present? && fechasalidam.present? && 
        fechallegadam < fechasalidam
      errors.add(:fechallegadam, 
                 " debe ser posterior a la fecha de salida en migracion")
    end
  end

  validate :rol_usuario
  def rol_usuario
    # current_usuario será nil cuando venga de validaciones por ejemplo
    # validate_presence_of :caso
    # que se hace desde acto
    if (defined?(current_usuario) &&
        current_usuario.rol != Ability::ROLADMIN &&
        current_usuario.rol != Ability::ROLDIR &&
        current_usuario.rol != Ability::ROLSIST &&
        current_usuario.rol != Ability::ROLCOOR &&
        current_usuario.rol != Ability::ROLANALI &&
        current_usuario.rol != Ability::ROLOFICIALPF &&
        current_usuario.rol != Ability::ROLGESTIONHUMANA) 
      errors.add(:id, "Rol de usuario no apropiado para editar")
    end
    if (defined?(current_usuario) &&
        current_usuario.rol == Ability::ROLSIST && 
        (casosjr.asesor != current_usuario.id))
      errors.add(:id, "Sistematizador solo puede editar sus casos")
    end
  end

end
