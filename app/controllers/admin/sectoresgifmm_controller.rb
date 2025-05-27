# frozen_string_literal: true

module Admin
  class SectoresgifmmController < Msip::Admin::BasicasController
    before_action :set_sectorgifmm,
      only: [:show, :edit, :update, :destroy]
    load_and_authorize_resource class: ::Sectorgifmm

    def clase
      "::Sectorgifmm"
    end

    def set_sectorgifmm
      @basica = Sectorgifmm.find(params[:id])
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

    def sectorgifmm_params
      params.require(:sectorgifmm).permit(*atributos_form)
    end
  end
end
