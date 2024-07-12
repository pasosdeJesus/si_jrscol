module Admin
  class TipostransferenciaController < Msip::Admin::BasicasController
    before_action :set_tipotransferencia, 
      only: [:show, :edit, :update, :destroy]
    load_and_authorize_resource  class: ::Tipotransferencia

    def clase 
      "::Tipotransferencia"
    end

    def set_tipotransferencia
      @basica = Tipotransferencia.find(params[:id])
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

    def tipotransferencia_params
      params.require(:tipotransferencia).permit(*atributos_form)
    end

  end
end
