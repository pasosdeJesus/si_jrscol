# frozen_string_literal: true

require_dependency "cor1440_gen/concerns/controllers/proyectosfinancieros_controller"

module Cor1440Gen
  class ProyectosfinancierosController < Heb412Gen::ModelosController
    include Cor1440Gen::Concerns::Controllers::ProyectosfinancierosController

    before_action :set_proyectofinanciero,
      only: [:show, :edit, :update, :destroy]
    skip_before_action :set_proyectofinanciero, only: [:validar]

    load_and_authorize_resource class: Cor1440Gen::Proyectofinanciero,
      only: [
        :new,
        :create,
        :destroy,
        :edit,
        :update,
        :index,
        :show,
        :objetivospf,
      ]

    def atributos_index
      atributos_index_cor1440 - [:titulo]
    end

    def filtra_contenido_params
    end

    def proyectofinanciero_params_si_jrscol
      a = proyectofinanciero_params_cor1440_gen
      a = a.reject do |e|
        e.is_a?(Hash) &&
          e.keys.include?(:actividadpf_attributes)
      end
      a << {
        actividadpf_attributes: [
          :id,
          :resultadopf_id,
          :actividadtipo_id,
          :nombrecorto,
          :titulo,
          :descripcion,
          :indicadorgifmm_id,
          :_destroy,
        ],
      }
    end

    def proyectofinanciero_params
      params.require(:proyectofinanciero).permit(
        proyectofinanciero_params_si_jrscol,
      )
    end
  end
end
