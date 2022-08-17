require 'date'
require 'sivel2_sjr/concerns/models/persona'

module Sip
  class Persona < ActiveRecord::Base
    include Sip::Modelo
    include Sivel2Sjr::Concerns::Models::Persona


    has_and_belongs_to_many :detallefinanciero, 
      class_name: '::Detallefinanciero',
      foreign_key: 'persona_id',
      association_foreign_key: 'detallefinanciero_id',
      join_table: 'detallefinanciero_persona'

    has_many :etiqueta_persona,  
      foreign_key: 'persona_id',
      validate: true,
      dependent: :destroy,
      class_name: 'Sip::EtiquetaPersona'
    has_many :etiqueta, 
      through: :etiqueta_persona, 
      class_name: 'Sip::Etiqueta'
    accepts_nested_attributes_for :etiqueta_persona, 
      allow_destroy: true, 
      reject_if: :all_blank

    has_one :datosbio, class_name: 'Sip::Datosbio', 
      foreign_key: 'persona_id', dependent: :delete
    accepts_nested_attributes_for :datosbio, reject_if: :all_blank

    validates :nombres, presence: true, allow_blank: false,
      length: { maximum: 100}

    validates :apellidos, presence: true, allow_blank: false,
      length: { maximum: 100}

    attr_accessor :fechanac
    def fechanac
      return Date.new(anionac && anionac > 0 ? anionac : 1900,
                  mesnac && mesnac > 0 && mesnac < 13 ? mesnac : 6,
                  dianac && dianac > 0 && dianac < 32 ? dianac : 15)
    end

    def fechanac=(valc)
      val = fecha_local_estandar valc
      p = val.split('-')
      self.anionac = p[0].to_i
      self.mesnac = p[1].to_i
      self.dianac = p[2].to_i
    end

    def nombres=(valc)
      self[:nombres] = valc.to_s.upcase.sub(/  */, ' ').sub(/^  */, '').sub(/  *$/, '')
    end

    def apellidos=(valc)
      self[:apellidos] = valc.to_s.upcase.sub(/  */, ' ').sub(/^  */, '').sub(/  *$/, '')
    end

    scope :filtro_etiqueta_ids, lambda {|e|
      joins(:etiqueta_persona).where("sip_etiqueta_persona.etiqueta_id" => e)
    }

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

  end
end

