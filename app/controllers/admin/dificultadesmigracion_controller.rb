module Admin
  class DificultadesmigracionController < Msip::Admin::BasicasController
    before_action :set_dificultadmigracion, 
      only: [:show, :edit, :update, :destroy]
    load_and_authorize_resource  class: ::Dificultadmigracion

    def clase 
      "::Dificultadmigracion"
    end

    def set_dificultadmigracion
      @basica = Dificultadmigracion.find(params[:id])
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

    def dificultadmigracion_params
      params.require(:dificultadmigracion).permit(*atributos_form)
    end

  end
end
