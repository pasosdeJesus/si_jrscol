# frozen_string_literal: true

module Admin
  class MiembrosfamiliarController < Msip::Admin::BasicasController
    before_action :set_miembrofamiliar,
      only: [:show, :edit, :update, :destroy]
    load_and_authorize_resource class: ::Miembrofamiliar

    def clase
      "::Miembrofamiliar"
    end

    def set_miembrofamiliar
      @basica = Miembrofamiliar.find(params[:id])
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

    def miembrofamiliar_params
      params.require(:miembrofamiliar).permit(*atributos_form)
    end
  end
end
