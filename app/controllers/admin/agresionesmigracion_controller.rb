module Admin
  class AgresionesmigracionController < Msip::Admin::BasicasController
    before_action :set_agresionmigracion, 
      only: [:show, :edit, :update, :destroy]
    load_and_authorize_resource  class: ::Agresionmigracion

    def clase 
      "::Agresionmigracion"
    end

    def set_agresionmigracion
      @basica = Agresionmigracion.find(params[:id])
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
      'F'
    end

    def agresionmigracion_params
      params.require(:agresionmigracion).permit(*atributos_form)
    end

  end
end
