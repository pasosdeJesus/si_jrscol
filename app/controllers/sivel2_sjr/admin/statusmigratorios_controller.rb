# frozen_string_literal: true

module Sivel2Sjr
  module Admin
    class StatusmigratoriosController < Msip::Admin::BasicasController
      before_action :set_statusmigratorio, only: [:show, :edit, :update, :destroy]
      load_and_authorize_resource class: Sivel2Sjr::Statusmigratorio

      def clase
        "Sivel2Sjr::Statusmigratorio"
      end

      def atributos_index
        [
          :id,
          :nombre,
          :observaciones,
          :formupersona,
          :habilitado,
        ]
      end

      # Use callbacks to share common setup or constraints between actions.
      def set_statusmigratorio
        @basica = Sivel2Sjr::Statusmigratorio.find(params[:id])
      end

      def genclase
        "M"
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def statusmigratorio_params
        params.require(:sivel2_sjr_statusmigratorio).permit(*atributos_form)
      end
    end
  end
end
