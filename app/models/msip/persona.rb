require 'sivel2_gen/concerns/models/persona'
require 'cor1440_gen/concerns/models/persona'

module Msip
  class Persona < ActiveRecord::Base
    include Sivel2Gen::Concerns::Models::Persona
    include Cor1440Gen::Concerns::Models::Persona

    belongs_to :ultimoperfilorgsocial, foreign_key: 'ultimoperfilorgsocial_id',
      validate: true, class_name: 'Msip::Perfilorgsocial', optional: false

    belongs_to :ultimoestatusmigratorio, 
      foreign_key: 'ultimoestatusmigratorio_id',
      validate: true, class_name: 'Sivel2Sjr::Statusmigratorio', 
      optional: true

    has_many :docidsecundario, 
      foreign_key: "persona_id",
      validate: true,
      dependent: :destroy, 
      class_name: '::Docidsecundario',
      inverse_of: :persona
    accepts_nested_attributes_for :docidsecundario, 
      allow_destroy: true, 
      reject_if: :all_blank

    has_many :casosjr, class_name: 'Sivel2Sjr::Casosjr',
      foreign_key: "contacto_id"

    has_and_belongs_to_many :detallefinanciero, 
      class_name: '::Detallefinanciero',
      foreign_key: 'persona_id',
      association_foreign_key: 'detallefinanciero_id',
      join_table: 'detallefinanciero_persona'

    has_one :datosbio, class_name: 'Msip::Datosbio', 
      foreign_key: 'persona_id', dependent: :delete
    accepts_nested_attributes_for :datosbio, reject_if: :all_blank

    validates :anionac, presence: {message: "Año de nacimiento requerido"}, allow_blank: false
    validates :mesnac, presence: {message: "Mes de nacimiento requerido. Si no lo conoce use Junio"}, allow_blank: false
    validates :dianac, presence: {message: "Día de nacimento requerido. Si no lo conoce use 15"}, allow_blank: false

    validates :nombres, presence: true, allow_blank: false,
      length: { maximum: 100}

    validates :apellidos, presence: true, allow_blank: false,
      length: { maximum: 100}

    validates :tdocumento, presence: true, allow_blank: false
    validates :numerodocumento, presence: true, allow_blank: false, 
      uniqueness: { scope: :tdocumento,
                    message: "Tipo y número de documento repetido" 
      }

    
    validates :sexo, inclusion: { 
      in: %w(H M O), message: "No puede tener sexo 'S'"
    }

    attr_accessor :fechanac
    def fechanac
      a = anionac && anionac > 0 ? anionac : 1900
      m = mesnac && mesnac > 0 && mesnac < 13 ? mesnac : 6
      d = dianac && dianac > 0 && dianac < 32 ? dianac : 15
      ud = Date.civil(a, m, -1)
      if d > ud.day
        puts "En beneficiario #{self.id} fecha de nacimiento invalida (#{a}, #{m}, #{d}) por (#{a}, #{m}, #{self.dianac})"
        d = ud.day
      end
      return Date.new(a, m, d)
    end

    def fechanac=(valc)
      val = fecha_local_estandar valc
      p = val.split('-')
      self.anionac = p[0].to_i
      self.mesnac = p[1].to_i
      self.dianac = p[2].to_i
    end

    attr_accessor :ppt
    validates :ppt, length: { maximum: 32}
    def ppt
      if tdocumento_id == 16
        return self.numerodocumento
      end
      if docidsecundario.where(tdocumento_id: 16).count == 1
        ds = docidsecundario.where(tdocumento_id: 16).take
        return ds.numero
      end
      return nil
    end

    def ppt=(valor)
      if valor.nil? || valor.to_s.strip == '' || valor.to_i == 0
        return
      end
      if tdocumento_id.nil? || tdocumento_id == 16
        self[:tdocumento_id] = 16
        self[:numerodocumento] = valor
        if self.docidsecundario.where(tdocumento_id: 16).count >= 1
          self.docidsecundario.where(tdocumento_id: 16).delete_all
        end
      elsif docidsecundario.where(tdocumento_id: 16).count == 1
        ds = docidsecundario.where(tdocumento_id: 16).take
        ds.numero = valor
      else
        ds = Docidsecundario.new(
          tdocumento_id: 16,
          numero: valor,
          persona_id: self.id
        )
        #if ds.valid?
        #  ds.save
        #else
        #  puts "** Problema guardando ppt como secundario"
        #end
        docidsecundario << ds
      end
    end

    # Modifican

    def apellidos=(valc)
      self[:apellidos] = valc.to_s.upcase.sub(/  */, ' ').sub(/^  */, '').sub(/  *$/, '')
    end

    def nombres=(valc)
      self[:nombres] = valc.to_s.upcase.sub(/  */, ' ').sub(/^  */, '').sub(/  *$/, '')
    end

    def numerodocumento=(valor)
      if tdocumento_id == 16 && 
          self.docidsecundario.where(tdocumento_id: 16).count >= 1
        self.docidsecundario.where(tdocumento_id: 16).delete_all
      end
      self[:numerodocumento] = valor
    end

    after_create :arreglar_sindocumento
    def arreglar_sindocumento
      if self.tdocumento_id == 11
        self.numerodocumento = Msip::PersonasController.
          mejora_nuevo_numerodocumento_sindoc(self.id)
      end
    end

    # Debe corresponder con la funcion @jrs_persona_presenta_nombre de 
    # app/assets/javascripts/actividad.js.coffee
    def presenta_nombre
      ip = numerodocumento ? numerodocumento : ''
      if tdocumento && tdocumento.sigla
        ip = tdocumento.sigla + ":" + ip
      end
      r = nombres + " " + apellidos + 
        " (" + ip + ")"
      return r
    end

    def en_blanco?
      self.nombres == 'N' &&
      self.apellidos == 'N' &&
      self.anionac.nil? &&
      self.mesnac.nil? &&
      self.dianac.nil? &&
      self.pais_id.nil? &&
      self.departamento_id.nil? &&
      self.municipio_id.nil? &&
      self.centropoblado_id.nil? &&
      self.ultimoperfilorgsocial_id.nil? &&
      self.ultimoestatusmigratorio_id.nil? &&
      self.ppt.nil?
    end
  end
end

