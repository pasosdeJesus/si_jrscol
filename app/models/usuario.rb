require 'sivel2_sjr/concerns/models/usuario'

class Usuario < ActiveRecord::Base
  include Sivel2Sjr::Concerns::Models::Usuario

  has_many :asesorhistorico,
    class_name: '::Asesorhistorico',
    validate: true, 
    foreign_key: :usuario_id

  has_many :bitacora,
    class_name: 'Msip::Bitacora',
    validate: false,
    foreign_key: :usuario_id,
    dependent: :nullify

  has_many :casosjr, 
    class_name: 'Sivel2Sjr::Casosjr',
    foreign_key: "asesor", 
    validate: true,
    dependent: :nullify

  has_many :etiqueta_persona,  
    foreign_key: 'usuario_id',
    validate: true,
    dependent: :destroy,
    class_name: 'Msip::EtiquetaPersona'

  has_many :etiqueta_usuario, class_name: 'Sivel2Sjr::EtiquetaUsuario',
    dependent: :delete_all

  has_many :etiqueta, class_name: 'Msip::Etiqueta',
    through: :etiqueta_usuario

  belongs_to :territorial, foreign_key: "territorial_id", validate: true,
    class_name: '::Territorial', optional: true

  validate :rol_usuario
  def rol_usuario
    #byebug
    if territorial && (rol == Ability::ROLADMIN ||
        rol == Ability::ROLINV || 
        rol == Ability::ROLDIR)
      errors.add(:territorial, "Territorial debe estar en blanco para el rol elegido")
    end
    if !territorial && rol != Ability::ROLADMIN && rol != Ability::ROLINV && 
        rol != Ability::ROLDIR
      errors.add(:territorial, "El rol elegido debe tener territorial")
    end
    if (etiqueta.count != 0 && rol != Ability::ROLINV) 
      errors.add(:etiqueta, "El rol elegido no requiere etiquetas de compartir")
    end
    if (!current_usuario.nil? && current_usuario.rol == Ability::ROLCOOR)
      if (territorial.nil? || 
          territorial.id != current_usuario.territorial_id)
        errors.add(:territorial, "Solo puede editar usuarios de su territorial")
      end
    end
  end

  scope :filtro_territorial_id, lambda {|o|
    where(territorial_id: o)
  }

  def active_for_authentication?
    #logger.debug self.to_yaml
    # Si fecha de contrato es posterior a hoy no puede autenticarse
    hoy = Date.today
    r = super && (!fincontrato || fincontrato >= hoy)
    return r
  end
end

