# frozen_string_literal: true

module Admin
  class MigracontactospreController < Msip::Admin::BasicasController
    before_action :set_migracontactopre,
      only: [:show, :edit, :update, :destroy]
    load_and_authorize_resource class: ::Migracontactopre

    def clase
      "::Migracontactopre"
    end

    def set_migracontactopre
      @basica = Migracontactopre.find(params[:id])
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

    def migracontactopre_params
      params.require(:migracontactopre).permit(*atributos_form)
    end
  end
end
