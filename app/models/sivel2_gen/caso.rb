# frozen_string_literal: true

require "sivel2_gen/concerns/models/caso"
module Sivel2Gen
  # Un grupo familiar atendido.
  class Caso < ActiveRecord::Base
    include Sivel2Gen::Concerns::Models::Caso

    has_many :actosjr,
      class_name: "Sivel2Sjr::Actosjr",
      through: :acto,
      dependent: :destroy
    accepts_nested_attributes_for :actosjr,
      allow_destroy: true,
      reject_if: :all_blank

    has_many :actonino,
      validate: true,
      dependent: :destroy,
      class_name: "::Actonino"
    accepts_nested_attributes_for :actonino,
      allow_destroy: true,
      reject_if: :all_blank

    has_one :casosjr,
      class_name: "Sivel2Sjr::Casosjr",
      inverse_of: :caso,
      validate: true,
      dependent: :destroy
    accepts_nested_attributes_for :casosjr,
      allow_destroy: true,
      update_only: true

    # respuesta deberìa ser con :through => :casosjr pero más dificil guardar
    has_many :respuesta,
      class_name: "Sivel2Sjr::Respuesta",
      validate: true,
      dependent: :destroy
    accepts_nested_attributes_for :respuesta,
      allow_destroy: true,
      reject_if: :all_blank

    has_many :desplazamiento,
      class_name: "Sivel2Sjr::Desplazamiento",
      validate: true,
      dependent: :destroy
    accepts_nested_attributes_for :desplazamiento,
      allow_destroy: true,
      reject_if: :all_blank
    has_many :victimasjr,
      class_name: "Sivel2Sjr::Victimasjr",
      through: :victima,
      dependent: :destroy
    accepts_nested_attributes_for :victimasjr,
      allow_destroy: true,
      reject_if: :all_blank

    has_many :migracion,
      class_name: "Sivel2Sjr::Migracion",
      validate: true,
      dependent: :destroy
    accepts_nested_attributes_for :migracion,
      allow_destroy: true,
      reject_if: :all_blank

    validate :beneficiarios_con_ultimoperfilorgsocial
    def beneficiarios_con_ultimoperfilorgsocial
      victima.each do |v|
        if !v._destroy && v.persona.ultimoperfilorgsocial_id.nil?
          errors.add(:persona, "Falta perfil poblacional de #{v.persona.presenta_nombre}")
        end
        if !v._destroy && [10, 11, 12].include?(v.persona.ultimoperfilorgsocial_id) &&
            v.persona.ultimoestatusmigratorio_id.nil?
          errors.add(:persona, "Falta estatus migratorio de #{v.persona.presenta_nombre}")
        end
      end
    end

    validate :oficina_en_territorial_del_usuario
    def oficina_en_territorial_del_usuario
      if defined?(current_usuario) && current_usuario &&
          current_usuario.rol &&
          current_usuario.rol != Ability::ROLADMIN &&
          current_usuario.rol != Ability::ROLDIR &&
          casosjr.oficina_id &&
          casosjr.oficina.territorial_id != current_usuario.territorial_id
        errors.add(
          :oficina,
          "Oficina debe ser de la territorial del usuario que diligencia",
        )
      end
    end

    validate :ppt_y_numero
    def ppt_y_numero
      migracion.each do |m|
        if m.fechasalida.nil?
          errors.add(
            :migracion,
            "En migración debe especificar fecha de salida",
          )
        end
        if m.numppt && m.numppt.length > 32
          errors.add(
            :migracion,
            "Longitud del número ppt no puede exceder 32 caracteres",
          )
        end
        if !m._destroy && m.statusmigratorio_id.nil?
          errors.add(
            :migracion,
            "En migración debe especificar estatus migratorio",
          )
        end
        if !m._destroy && m.perfilmigracion_id.nil?
          errors.add(
            :migracion,
            "En migración debe especificar perfil de migración",
          )
        end
        next unless m.pep && (m.numppt.nil? || m.numppt == "")

        errors.add(
          :migracion,
          "Si el migrante tiene PPT debe especificar el número",
        )
      end
    end

    def presenta(atr)
      case atr.to_s
      when "fecharec"
        casosjr.fecharec if casosjr && casosjr.fecharec
      when "oficina"
        casosjr.oficina.nombre if casosjr && casosjr.oficina
      when "asesor"
        casosjr.usuario.nusuario if casosjr && casosjr.usuario
      when "contacto"
        if casosjr && casosjr.contacto
          casosjr.contacto.nombres + " " + casosjr.contacto.apellidos +
            " " + (if casosjr.contacto.tdocumento.nil? ||
                    casosjr.contacto.tdocumento.sigla.nil?
                     ""
                   else
                     casosjr.contacto.tdocumento.sigla
                   end) + " " +
            " " + (if casosjr.contacto.numerodocumento.nil?
                     ""
                   else
                     casosjr.contacto.numerodocumento
                   end)
        end
      when "direccion"
        casosjr.direccion if casosjr && casosjr.direccion
      when "telefono"
        casosjr.telefono if casosjr && casosjr.telefono
      else
        presenta_gen(atr)
      end
    end
  end
end
