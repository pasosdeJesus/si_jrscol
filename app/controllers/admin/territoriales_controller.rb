# frozen_string_literal: true

module Admin
  class TerritorialesController < Msip::Admin::BasicasController

    before_action :set_territorial, 
      only: [:show, :edit, :update, :destroy]
    load_and_authorize_resource class: ::Territorial

    def atributos_index
      [:id,
       :nombre,
       :observaciones,
       :pais_id,
       :departamento_id,
       :municipio_id,
       :centropoblado_id,
       :fechacreacion_localizada,
       :habilitado
      ]
    end


    def clase 
      "::Territorial"
    end

    def set_territorial
      @basica = Territorial.find(params[:id])
    end

    def genclase
      'F'
    end

    def territorial_params
      params.require(:territorial).permit(*atributos_form)
    end


  end
end
