# frozen_string_literal: true

module Admin
  class CausasmigracionController < Msip::Admin::BasicasController
    before_action :set_causamigracion,
      only: [:show, :edit, :update, :destroy]
    load_and_authorize_resource class: ::Causamigracion

    def clase
      "::Causamigracion"
    end

    def set_causamigracion
      @basica = Causamigracion.find(params[:id])
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

    def causamigracion_params
      params.require(:causamigracion).permit(*atributos_form)
    end
  end
end
