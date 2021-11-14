module Sivel2Sjr
  module Admin
    class MotivossjrController < Sip::Admin::BasicasController
      before_action :set_motivosjr, only: [:show, :edit, :update, :destroy]
      load_and_authorize_resource class: Sivel2Sjr::Motivosjr

      def clase 
        "Sivel2Sjr::Motivosjr"
      end

      def atributos_index
        ["id",  "nombre" ] + 
          [ :derecho_ids =>  [] ] +
          ["observaciones", "fechacreacion", "fechadeshabilitacion"] 
      end

      def new
        new_gen
        @registro.nombre = 'N '+Time.now.to_i.to_s
        @registro.save!(validate: false)
        redirect_to sivel2_sjr.edit_admin_motivosjr_path(@registro)
      end

      # Use callbacks to share common setup or constraints between actions.
      def set_motivosjr
        @basica = Sivel2Sjr::Motivosjr.find(params[:id])
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def motivosjr_params
        params.require(:motivosjr).permit(*atributos_form)
      end

    end
  end
end
