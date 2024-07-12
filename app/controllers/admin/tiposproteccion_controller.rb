module Admin
  class TiposproteccionController < Msip::Admin::BasicasController
    before_action :set_tipoproteccion, 
      only: [:show, :edit, :update, :destroy]
    load_and_authorize_resource  class: ::Tipoproteccion

    def clase 
      "::Tipoproteccion"
    end

    def set_tipoproteccion
      @basica = Tipoproteccion.find(params[:id])
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

    def tipoproteccion_params
      params.require(:tipoproteccion).permit(*atributos_form)
    end

  end
end
