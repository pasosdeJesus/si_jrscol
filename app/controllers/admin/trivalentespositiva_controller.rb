# frozen_string_literal: true

module Admin
  class TrivalentespositivaController < Msip::Admin::BasicasController
    before_action :set_trivalentepositiva,
      only: [:show, :edit, :update, :destroy]
    load_and_authorize_resource class: ::Trivalentepositiva

    def clase
      "::Trivalentepositiva"
    end

    def set_trivalentepositiva
      @basica = Trivalentepositiva.find(params[:id])
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
      "F"
    end

    def trivalentepositiva_params
      params.require(:trivalentepositiva).permit(*atributos_form)
    end
  end
end
