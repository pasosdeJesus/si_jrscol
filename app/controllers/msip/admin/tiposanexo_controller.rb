# frozen_string_literal: true

module Msip
  module Admin
    class TiposanexoController < Msip::Admin::BasicasController
      before_action :set_tipoanexo,
        only: [:show, :edit, :update, :destroy]
      load_and_authorize_resource class: Msip::Tipoanexo

      def clase
        "Msip::Tipoanexo"
      end

      def set_tipoanexo
        @basica = Msip::Tipoanexo.find(params[:id])
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

      def tipoanexo_params
        params.require(:tipoanexo).permit(*atributos_form)
      end
    end
  end
end
