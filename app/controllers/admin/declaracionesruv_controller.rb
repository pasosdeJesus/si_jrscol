module Admin
  class DeclaracionesruvController < Msip::Admin::BasicasController
    before_action :set_declaracionruv, 
      only: [:show, :edit, :update, :destroy]
    load_and_authorize_resource  class: ::Declaracionruv

    def clase 
      "::Declaracionruv"
    end

    def set_declaracionruv
      @basica = Declaracionruv.find(params[:id])
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

    def declaracionruv_params
      params.require(:declaracionruv).permit(*atributos_form)
    end

  end
end
