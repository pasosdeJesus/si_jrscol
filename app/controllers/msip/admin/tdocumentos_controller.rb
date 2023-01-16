require 'msip/concerns/controllers/tdocumentos_controller'

module Msip
  module Admin
    class TdocumentosController < Msip::Admin::BasicasController

      before_action :set_tdocumento, only: [:show, :edit, :update, :destroy]
      load_and_authorize_resource class: Msip::Tdocumento

      include Msip::Concerns::Controllers::TdocumentosController

      def atributos_index
        [
          :id, 
          :nombre, 
          :sigla, 
          :formatoregex, 
          :ayuda,
          :observaciones,
          :fechacreacion_localizada, 
          :habilitado
        ]
      end

      def tdocumento_params
        params.require(:tdocumento).permit( *(atributos_form))
      end

    end
  end
end
