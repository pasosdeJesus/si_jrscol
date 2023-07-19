module Admin
  class ProductoslegController < Msip::Admin::BasicasController
    before_action :set_productoleg, 
      only: [:show, :edit, :update, :destroy]
    load_and_authorize_resource  class: ::Productoleg

    def clase 
      "::Productoleg"
    end

    def set_productoleg
      @basica = Productoleg.find(params[:id])
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

    def genclase
      'M'
    end

    def productoleg_params
      params.require(:productoleg).permit(*atributos_form)
    end

  end
end
