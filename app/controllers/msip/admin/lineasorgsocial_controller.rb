# frozen_string_literal: true

module Msip
  module Admin
    class LineasorgsocialController < Msip::Admin::BasicasController
      before_action :set_lineaorgsocial,
        only: [:show, :edit, :update, :destroy]
      load_and_authorize_resource class: Msip::Lineaorgsocial

      def clase
        "Msip::Lineaorgsocial"
      end

      def set_lineaorgsocial
        @basica = Msip::Lineaorgsocial.find(params[:id])
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

      def genclase
        "F"
      end

      def lineaorgsocial_params
        params.require(:lineaorgsocial).permit(*atributos_form)
      end
    end
  end
end
