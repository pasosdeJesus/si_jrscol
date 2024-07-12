module Admin
  class PerfilesmigracionController < Msip::Admin::BasicasController
    before_action :set_perfilmigracion, 
      only: [:show, :edit, :update, :destroy]
    load_and_authorize_resource  class: ::Perfilmigracion

    def clase 
      "::Perfilmigracion"
    end

    def set_perfilmigracion
      @basica = Perfilmigracion.find(params[:id])
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

    def perfilmigracion_params
      params.require(:perfilmigracion).permit(*atributos_form)
    end

  end
end
