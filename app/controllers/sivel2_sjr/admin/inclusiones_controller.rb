module Sivel2Sjr
  module Admin
    class InclusionesController < Msip::Admin::BasicasController
      before_action :set_inclusion, only: [:show, :edit, :update, :destroy]
      load_and_authorize_resource class: Sivel2Sjr::Inclusion

      def clase 
        "Sivel2Sjr::Inclusion"
      end

      # Usar retroallmadas para compartir configuracion
      def set_inclusion
        @basica = Sivel2Sjr::Inclusion.find(params[:id])
      end

      def genclase
        return 'F';
      end

      def atributos_index
        [:id,
         :nombre,
         :observaciones,
         :pospres,
         :fechacreacion_localizada,
         :habilitado
        ]
      end


      # No confiar en parametros de internet, sino solo los de lista blanca
      def inclusion_params
        params.require(:sivel2_sjr_inclusion).permit(*atributos_form)
      end


    end
  end
end
