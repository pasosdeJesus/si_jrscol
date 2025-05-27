# frozen_string_literal: true

require "sivel2_gen/concerns/models/persona"
require "cor1440_gen/concerns/models/persona"

module Msip
  # Datos de un beneficiario
  class Persona < ActiveRecord::Base
    include Sivel2Gen::Concerns::Models::Persona
    include Cor1440Gen::Concerns::Models::Persona

    belongs_to :ultimadiscapacidad,
      validate: true,
      class_name: "::Discapacidad",
      optional: false

    belongs_to :ultimoperfilorgsocial,
      validate: true,
      class_name: "Msip::Perfilorgsocial",
      optional: false

    belongs_to :ultimoestatusmigratorio,
      validate: true,
      class_name: "Sivel2Sjr::Statusmigratorio",
      optional: true

    has_many :docidsecundario,
      validate: true,
      dependent: :destroy,
      class_name: "::Docidsecundario",
      inverse_of: :persona
    accepts_nested_attributes_for :docidsecundario,
      allow_destroy: true,
      reject_if: :all_blank

    has_many :casosjr,
      class_name: "Sivel2Sjr::Casosjr",
      foreign_key: "contacto_id"

    has_and_belongs_to_many :detallefinanciero,
      class_name: "::Detallefinanciero",
      association_foreign_key: "detallefinanciero_id",
      join_table: "detallefinanciero_persona"

    validates :anionac, presence: { message: "Año de nacimiento requerido" }, allow_blank: false
    validates :mesnac, presence: { message: "Mes de nacimiento requerido. Si no lo conoce use Junio" }, allow_blank: false
    validates :dianac, presence: { message: "Día de nacimento requerido. Si no lo conoce use 15" }, allow_blank: false

    validates :nombres,
      presence: true,
      allow_blank: false,
      length: { maximum: 100 }
    validates :apellidos,
      presence: true,
      allow_blank: false,
      length: { maximum: 100 }

    validates :telefono, length: { maximum: 127 }

    validates :tdocumento, presence: true, allow_blank: false
    validates :numerodocumento,
      presence: true,
      allow_blank: false,
      uniqueness: {
        scope: :tdocumento,
        message: "Tipo y número de documento repetido",
      }

    validates :sexo, inclusion: {
      in: ["H", "M", "O"], message: "No puede tener sexo 'S'",
    }

    attr_accessor :fechanac

    def fechanac
      a = anionac && anionac > 0 ? anionac : 1900
      m = mesnac && mesnac > 0 && mesnac < 13 ? mesnac : 6
      d = dianac && dianac > 0 && dianac < 32 ? dianac : 15
      ud = Date.civil(a, m, -1)
      if d > ud.day
        puts "En beneficiario #{id} fecha de nacimiento invalida (#{a}, #{m}, #{d}) por (#{a}, #{m}, #{dianac})"
        d = ud.day
      end
      Date.new(a, m, d)
    end

    def fechanac=(valc)
      val = fecha_local_estandar(valc)
      p = val.split("-")
      self.anionac = p[0].to_i
      self.mesnac = p[1].to_i
      self.dianac = p[2].to_i
    end

    attr_accessor :ppt

    validates :ppt, length: { maximum: 32 }
    def ppt
      if tdocumento_id == 16
        return numerodocumento
      end

      if docidsecundario.where(tdocumento_id: 16).count == 1
        ds = docidsecundario.find_by(tdocumento_id: 16)
        return ds.numero
      end
      nil
    end

    def ppt=(valor)
      if valor.nil? || valor.to_s.strip == "" || valor.to_i == 0
        return
      end

      if tdocumento_id.nil? || tdocumento_id == 16
        self[:tdocumento_id] = 16
        self[:numerodocumento] = valor
        if docidsecundario.where(tdocumento_id: 16).count >= 1
          docidsecundario.where(tdocumento_id: 16).delete_all
        end
      elsif docidsecundario.where(tdocumento_id: 16).count == 1
        ds = docidsecundario.find_by(tdocumento_id: 16)
        ds.numero = valor
      else
        ds = Docidsecundario.new(
          tdocumento_id: 16,
          numero: valor,
          persona_id: id,
        )
        # if ds.valid?
        #  ds.save
        # else
        #  puts "** Problema guardando ppt como secundario"
        # end
        docidsecundario << ds
      end
    end

    # Modifican

    def apellidos=(valc)
      self[:apellidos] = valc.to_s.upcase.sub(/  */, " ").sub(/^  */, "").sub(/  *$/, "")
    end

    def nombres=(valc)
      self[:nombres] = valc.to_s.upcase.sub(/  */, " ").sub(/^  */, "").sub(/  *$/, "")
    end

    def numerodocumento=(valor)
      if tdocumento_id == 16 &&
          docidsecundario.where(tdocumento_id: 16).count >= 1
        docidsecundario.where(tdocumento_id: 16).delete_all
      end
      self[:numerodocumento] = valor
    end

    after_create :arreglar_sindocumento
    def arreglar_sindocumento
      if tdocumento_id == 11
        self.numerodocumento = Msip::PersonasController
          .mejora_nuevo_numerodocumento_sindoc(numerodocumento, id)
      end
    end

    # Debe corresponder con la funcion @jrs_persona_presenta_nombre de
    # app/assets/javascripts/actividad.js.coffee
    def presenta_nombre
      ip = numerodocumento ? numerodocumento : ""
      if tdocumento && tdocumento.sigla
        ip = tdocumento.sigla + ":" + ip
      end
      r = nombres.to_s + " " + apellidos.to_s +
        " (" + ip + ")"
      r
    end

    def en_blanco?
      nombres == "N" &&
        apellidos == "N" &&
        anionac.nil? &&
        mesnac.nil? &&
        dianac.nil? &&
        pais_id.nil? &&
        departamento_id.nil? &&
        municipio_id.nil? &&
        centropoblado_id.nil? &&
        ultimoperfilorgsocial_id.nil? &&
        ultimoestatusmigratorio_id.nil? &&
        ppt.nil?
    end
  end
end
