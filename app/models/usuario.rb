# frozen_string_literal: true

require "sivel2_gen/concerns/models/usuario"

# Un usuario el sistema
class Usuario < ActiveRecord::Base
  include Sivel2Gen::Concerns::Models::Usuario

  belongs_to :oficina,
    validate: true,
    class_name: "Msip::Oficina",
    optional: true

  belongs_to :territorial,
    class_name: "::Territorial",
    validate: true,
    optional: true

  has_many :asesorhistorico,
    class_name: "::Asesorhistorico",
    validate: true

  has_many :bitacora,
    class_name: "Msip::Bitacora",
    validate: false,
    dependent: :nullify

  has_many :casosjr,
    class_name: "Sivel2Sjr::Casosjr",
    foreign_key: "asesor",
    validate: true,
    dependent: :nullify

  has_many :etiqueta_persona,
    validate: true,
    dependent: :destroy,
    class_name: "Msip::EtiquetaPersona"

  has_many :etiqueta_usuario,
    class_name: "Sivel2Sjr::EtiquetaUsuario",
    dependent: :delete_all

  has_many :etiqueta,
    class_name: "Msip::Etiqueta",
    through: :etiqueta_usuario

  validate :rol_usuario
  def rol_usuario
    # byebug
    if territorial && (rol == Ability::ROLADMIN ||
        rol == Ability::ROLINV ||
        rol == Ability::ROLDIR)
      errors.add(:territorial, "Territorial debe estar en blanco para el rol elegido")
    end
    if !territorial && rol != Ability::ROLADMIN && rol != Ability::ROLINV &&
        rol != Ability::ROLDIR
      errors.add(:territorial, "El rol elegido debe tener territorial")
    end
    if etiqueta.count != 0 && rol != Ability::ROLINV
      errors.add(:etiqueta, "El rol elegido no requiere etiquetas de compartir")
    end
    if !current_usuario.nil? && current_usuario.rol == Ability::ROLCOOR
      if territorial.nil? ||
          territorial.id != current_usuario.territorial_id
        errors.add(:territorial, "Solo puede editar usuarios de su territorial")
      end
    end
  end

  scope :filtro_oficina_id, lambda { |o|
    where(oficina_id: o)
  }

  scope :filtro_territorial_id, lambda { |o|
    where(territorial_id: o)
  }

  attr_reader :aproxoficina_id
  attr_reader :aproxoficina

  def aproxoficina_id
    territorial.nil? || territorial.oficina_ids.count == 0 ? 1 : territorial.oficina_ids[0]
  end

  def aproxoficina
    if aproxoficina_id.nil?
      Msip::Oficina.find(1)
    else
      Msip::Oficina.find(aproxoficina_id)
    end
  end

  def active_for_authentication?
    # logger.debug self.to_yaml
    # Si fecha de contrato es posterior a hoy no puede autenticarse
    hoy = Date.today
    r = super && (!fincontrato || fincontrato >= hoy)
    r
  end
end
