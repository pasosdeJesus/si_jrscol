module Sip
  module Admin
    class TdocumentosController < Sip::Admin::BasicasController
      before_action :set_tipoanexo, 
        only: [:show, :edit, :update, :destroy]
      load_and_authorize_resource  class: Sip::Tdocumento

      def clase 
        "Sip::Tdocumento"
      end

      def set_tipoanexo
        @basica = Sip::Tdocumento.find(params[:id])
      end

      def atributos_index
        [
          "id", 
          "nombre", 
          "observaciones",
          "ayuda",
          "fechacreacion_localizada", 
          "habilitado"
        ]
      end

      def genclase
        'M'
      end

      def tipoanexo_params
        params.require(:tdocumento).permit(*atributos_form)
      end

    end
  end
end
