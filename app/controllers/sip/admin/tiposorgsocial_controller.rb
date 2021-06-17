# encoding: UTF-8

module Sip
  module Admin
    class TiposorgsocialController < Sip::Admin::BasicasController
      before_action :set_tipoorgsocial, 
        only: [:show, :edit, :update, :destroy]
      load_and_authorize_resource  class: Sip::Tipoorgsocial

      def clase 
        "Sip::Tipoorgsocial"
      end

      def set_tipoorgsocial
        @basica = Sip::Tipoorgsocial.find(params[:id])
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
        'M'
      end

      def tipoorgsocial_params
        params.require(:tipoorgsocial).permit(*atributos_form)
      end

    end
  end
end
