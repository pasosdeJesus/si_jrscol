# frozen_string_literal: true

module Admin
  class DiscapacidadesController < Msip::Admin::BasicasController
    before_action :set_discapacidad,
      only: [:show, :edit, :update, :destroy]
    load_and_authorize_resource class: ::Discapacidad

    def clase
      "::Discapacidad"
    end

    def set_discapacidad
      @basica = Discapacidad.find(params[:id])
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

    def discapacidad_params
      params.require(:discapacidad).permit(*atributos_form)
    end
  end
end
