module Sip
  module Admin
    class LineasorgsocialController < Sip::Admin::BasicasController

      before_action :set_lineaorgsocial, 
        only: [:show, :edit, :update, :destroy]
      load_and_authorize_resource  class: Sip::Lineaorgsocial
  
      def clase 
        "Sip::Lineaorgsocial"
      end
  
      def set_lineaorgsocial
        @basica = Sip::Lineaorgsocial.find(params[:id])
      end
  
      def atributos_index
        [
          "id", 
          "nombre", 
          "observaciones", 
          "fechacreacion_localizada", 
          "habilitado"
        ]
      end
  
      def genclase
        'F'
      end
  
      def lineaorgsocial_params
        params.require(:lineaorgsocial).permit(*atributos_form)
      end
  
    end
  end
end
