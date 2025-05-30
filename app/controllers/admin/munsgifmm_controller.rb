# frozen_string_literal: true

module Admin
  class MunsgifmmController < Msip::Admin::BasicasController
    before_action :set_mungifmm,
      only: [:show, :edit, :update, :destroy]
    load_and_authorize_resource class: ::Mungifmm

    def clase
      "::Mungifmm"
    end

    def set_mungifmm
      @basica = Mungifmm.find(params[:id])
    end

    def atributos_index
      [
        :id,
        :nombre,
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

    def mungifmm_params
      params.require(:mungifmm).permit(*atributos_form)
    end
  end
end
