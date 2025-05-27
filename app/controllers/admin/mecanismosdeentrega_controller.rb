# frozen_string_literal: true

module Admin
  class MecanismosdeentregaController < Msip::Admin::BasicasController
    before_action :set_mecanismodeentrega,
      only: [:show, :edit, :update, :destroy]
    load_and_authorize_resource class: ::Mecanismodeentrega

    def clase
      "::Mecanismodeentrega"
    end

    def set_mecanismodeentrega
      @basica = Mecanismodeentrega.find(params[:id])
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

    def mecanismodeentrega_params
      params.require(:mecanismodeentrega).permit(*atributos_form)
    end
  end
end
