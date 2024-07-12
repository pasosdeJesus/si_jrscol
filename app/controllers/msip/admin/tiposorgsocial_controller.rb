module Msip
  module Admin
    class TiposorgsocialController < Msip::Admin::BasicasController

      before_action :set_tipoorgsocial, 
        only: [:show, :edit, :update, :destroy]
      load_and_authorize_resource  class: Msip::Tipoorgsocial

      def clase 
        "Msip::Tipoorgsocial"
      end

      def set_tipoorgsocial
        @basica = Msip::Tipoorgsocial.find(params[:id])
      end

      def atributos_index
        [
          :id, 
          :nombre, 
          :observaciones, 
          :fechacreacion_localizada, 
          :habilitado
        ]
      end

      def atributos_form
        a = atributos_index - [:id]
        return a.map do |e|
          e == :fechacreacion_localizada ? :fechacreacion : 
            (e == :habilitado ? :fechadeshabilitacion : e)
        end
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
