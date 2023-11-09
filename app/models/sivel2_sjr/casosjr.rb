module Sivel2Sjr
  class Casosjr < ActiveRecord::Base

    include Msip::Modelo

    self.table_name = 'sivel2_sjr_casosjr'

    self.primary_key = :caso_id

    # Ordenados por foreign_key para comparar con esquema en base
    belongs_to :usuario, class_name: "Usuario", 
      foreign_key: "asesor", validate: true, optional: false
    belongs_to :comosupo, class_name: "Sivel2Sjr::Comosupo", 
      foreign_key: "comosupo_id", validate: true, optional: true
    belongs_to :contacto, class_name: "Msip::Persona",  
      foreign_key: "contacto_id", optional: false
    belongs_to :caso, class_name: "Sivel2Gen::Caso", validate: true,
      foreign_key: "caso_id", inverse_of: :casosjr, optional: false
    belongs_to :categoria, class_name: "Sivel2Gen::Categoria", 
      validate: true, foreign_key: "categoriaref", optional: true
    belongs_to :idioma, class_name: "Sivel2Sjr::Idioma", 
      foreign_key: "idioma_id", validate: true, optional: true
    belongs_to :llegada, class_name: "Msip::Ubicacion", validate: true,
      foreign_key: "llegada_id", optional: true
    belongs_to :llegadam, class_name: 'Msip::Ubicacion', validate: true,
      foreign_key: 'llegada_idm', optional: true
    belongs_to :proteccion, class_name: "Sivel2Sjr::Proteccion", 
      foreign_key: "proteccion_id", validate: true, optional: true
    belongs_to :oficina, class_name: "Msip::Oficina", 
      foreign_key: "oficina_id", validate: true, optional: true
    belongs_to :salida, class_name: "Msip::Ubicacion", validate: true,
      foreign_key: "salida_id", optional: true
    belongs_to :salidam, class_name: 'Msip::Ubicacion', validate: true,
      foreign_key: 'salida_idm', optional: true
    belongs_to :statusmigratorio, 
      class_name: "Sivel2Sjr::Statusmigratorio", 
      foreign_key: "estatusmigratorio_id", validate: true, optional: true

    has_many :actividad_casosjr, 
      class_name: 'Sivel2Sjr::ActividadCasosjr',
      validate: true, 
      foreign_key: :casosjr_id
    has_many :actividad, through: :actividad_casosjr
    accepts_nested_attributes_for :actividad_casosjr, 
      reject_if: :all_blank
    accepts_nested_attributes_for :actividad, reject_if: :all_blank

    has_many :asesorhistorico,
      class_name: '::Asesorhistorico',
      validate: true, 
      foreign_key: :casosjr_id

    has_many :respuesta, class_name: "Sivel2Sjr::Respuesta", 
      validate: true, foreign_key: "caso_id"#, dependent: :destroy

    has_many :victima, class_name: 'Sivel2Gen::Victima', validate: true,
      through: :caso

    has_many :victimasjr, class_name: 'Sivel2Sjr::Victimasjr', validate: true,
      through: :victima

    attr_reader :territorial_id
    def territorial_id
      oficina_id.nil? ? 1 : oficina.territorial_id
    end

    validates :asesor, presence: true
    #_presence_of :asesor
    validates :contacto, uniqueness: { 
      message: 'Contacto no puede estar repetido en dos casos' 
    }
    validates :docrefugiado, length: { maximum: 128 }
    validates :estatus_refugio, length: { maximum: 5000 }
    validates :fecharec, presence: true
    #_presence_of :fecharec
    validates :motivom, length: { maximum: 5000 }
    validates :memo1612, length: { maximum: 5000 }
    validates :oficina, presence: true
    #_presence_of :oficina


    validate :fecharec_pasada
    def fecharec_pasada
      if fecharec && fecharec>Date.today
        errors.add(:fecharec, 
                   " la fecha de recepción debe ser en el pasado")
      end
    end

    validate :llegada_posterior_a_salida
    def llegada_posterior_a_salida
      if fechallegada.present? && fechasalida.present? && 
          fechallegada < fechasalida
        errors.add(:fechallegada, 
                   " debe ser posterior a la fecha de salida")
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

    validate :oficina_en_territorial_del_usuario
    def oficina_en_territorial_del_usuario
      if (defined?(caso.current_usuario) && caso.current_usuario &&
          caso.current_usuario.rol &&
          caso.current_usuario.rol != Ability::ROLADMIN &&
          caso.current_usuario.rol != Ability::ROLDIR &&
          self.oficina_id &&
          self.oficina.territorial_id != caso.current_usuario.territorial_id)
        errors.add(:oficina,
                   "Oficina debe ser de la territorial del usuario que diligencia")
      end
    end

    validate :rol_usuario
    def rol_usuario
      # current_usuario será nil cuando venga de validaciones por ejemplo
      # validate_presence_of :caso
      # que se hace desde acto
      if (defined?(caso.current_usuario) && !caso.current_usuario.nil? &&
          caso.current_usuario.rol != Ability::ROLADMIN &&
          caso.current_usuario.rol != Ability::ROLDIR &&
          caso.current_usuario.rol != Ability::ROLSIST &&
          caso.current_usuario.rol != Ability::ROLCOOR &&
          caso.current_usuario.rol != Ability::ROLANALI &&
          caso.current_usuario.rol != Ability::ROLOFICIALPF &&
          caso.current_usuario.rol != Ability::ROLGESTIONHUMANA) 
        errors.add(:id, "Rol de usuario no apropiado para editar")
      end
      if (defined?(caso.current_usuario) && !caso.current_usuario.nil? &&
          caso.current_usuario.rol == Ability::ROLSIST && 
          (casosjr.asesor != caso.current_usuario.id))
        errors.add(:id, "Sistematizador solo puede editar sus casos")
      end
    end

    validate :sitiosm_diferentes
    def sitiosm_diferentes
      if llegadam.present? && salidam.present? && llegada_idm == salida_idm
        errors.add(:llegadam, 
                   " debe ser diferente al sitio de salida en migración")
      end
    end

    # Verifica que un usuario sea de la misma territorial de otro
    def self.asesor_de_territorial(current_usuario, usuario, territorial)
      current_usuario.rol == Ability::ROLADMIN ||
        current_usuario.rol == Ability::ROLDIR ||
        usuario.rol == Ability::ROLADMIN ||
        usuario.rol == Ability::ROLDIR ||
        usuario.territorial_id == territorial.id || territorial.id == 1
    end

    # Verifica que un usuario edita caso de su territorial
    def self.asesor_edita_de_su_territorial(current_usuario, territorial)
      (current_usuario.rol != Ability::ROLSIST &&
       current_usuario.rol != Ability::ROLCOOR &&
       current_usuario.rol != Ability::ROLANALI) ||
      territorial.id == current_usuario.territorial_id
    end

    before_destroy do
      no_borra_con_actividades 
      if errors.present?
        throw(:abort) 
      end
    end

    def no_borra_con_actividades
      if actividad_casosjr.count > 0
        errors.add(:base, 'Beneficiario de actividades ('+
                   actividad_casosjr.pluck(:actividad_id).join(', ') + ')') 
      end
    end


    # Funciones auxiliares

    def beneficiarios_activos
      self.victimasjr.where(fechadesagregacion: nil)
    end

    def actividades_con_beneficiarios_activos_en_asistencia_ids
      bids = beneficiarios_activos.pluck(:persona_id)
      Cor1440Gen::Asistencia.joins(:persona).
        where("msip_persona.id IN (?)", bids).
        pluck('actividad_id')
    end

    def actividades_con_caso_ids
      t = self.actividad_ids |
        actividades_con_beneficiarios_activos_en_asistencia_ids
    end

  end
end
