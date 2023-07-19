module Admin
  class ProveedoresController < Msip::Admin::BasicasController
    before_action :set_proveedor, 
      only: [:show, :edit, :update, :destroy]
    load_and_authorize_resource  class: ::Proveedor

    def clase 
      "::Proveedor"
    end

    def set_proveedor
      @basica = Proveedor.find(params[:id])
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

    def proveedor_params
      params.require(:proveedor).permit(*atributos_form)
    end

  end
end
