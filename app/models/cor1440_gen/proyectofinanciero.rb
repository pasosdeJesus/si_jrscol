require 'cor1440_gen/concerns/models/proyectofinanciero'

module Cor1440Gen
  class Proyectofinanciero < ActiveRecord::Base

    include Cor1440Gen::Concerns::Models::Proyectofinanciero


    has_and_belongs_to_many :oficina, 
      class_name: 'Sip::Oficina',
      foreign_key: 'proyectofinanciero_id',
      association_foreign_key: "oficina_id",
      join_table: 'sivel2_sjr_oficina_proyectofinanciero'

    scope :filtro_oficina_ids, lambda { |o|
      joins('JOIN sivel2_sjr_oficina_proyectofinanciero ON ' +
            'sivel2_sjr_oficina_proyectofinanciero.proyectofinanciero_id=cor1440_gen_proyectofinanciero.id').
            where('sivel2_sjr_oficina_proyectofinanciero.oficina_id=?', o)
    }

    # Recibe un grupo de proyectosfinancieros y los filtra 
    # de acuerdo al control de acceso del usuario o a 
    # otros parametros recibidos
    def filtra_acceso(current_usuario, pf, params = nil)
      if params && params[:filtro] && params[:filtro][:busoficina] &&
        params[:filtro][:busoficina] != ''
        pf = pf.joins(:oficina_proyectofinanciero).
          where('sivel2_sjr_oficina_proyectofinanciero.oficina_id = ?',
                params[:filtro][:busoficina])
      end
      return pf
    end

    # Id del proyecto con actividades comunes vigente
    # nil significa que no hay
    def self.actividades_comunes_id
      return 10
    end

    # Id de un proyecto que deba agregarse siempre a toda actividad
    # nil significa que no hay.
    def self.en_toda_actividad_id
      return 10
    end

  end
end
