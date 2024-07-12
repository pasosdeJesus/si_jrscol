module Admin
  class FrecuenciasentregaController < Msip::Admin::BasicasController
    before_action :set_frecuenciaentrega, 
      only: [:show, :edit, :update, :destroy]
    load_and_authorize_resource  class: ::Frecuenciaentrega

    def clase 
      "::Frecuenciaentrega"
    end

    def set_frecuenciaentrega
      @basica = Frecuenciaentrega.find(params[:id])
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

    def frecuenciaentrega_params
      params.require(:frecuenciaentrega).permit(*atributos_form)
    end

  end
end
