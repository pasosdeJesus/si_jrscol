# frozen_string_literal: true

module Admin
  class UnidadesayudaController < Msip::Admin::BasicasController
    before_action :set_unidadayuda,
      only: [:show, :edit, :update, :destroy]
    load_and_authorize_resource class: ::Unidadayuda

    def clase
      "::Unidadayuda"
    end

    def set_unidadayuda
      @basica = Unidadayuda.find(params[:id])
    end

    def atributos_index
      [
        :id,
        :nombre,
        :orden,
        :observaciones,
        :fechacreacion_localizada,
        :habilitado,
      ]
    end

    def atributos_form
      a = atributos_index - [:id]
      a.map do |e|
        if e == :fechacreacion_localizada
          :fechacreacion
        else
          (e == :habilitado ? :fechadeshabilitacion : e)
        end
      end
    end

    def genclase
      "M"
    end

    def unidadayuda_params
      params.require(:unidadayuda).permit(*atributos_form)
    end
  end
end
