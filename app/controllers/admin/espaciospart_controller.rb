module Admin
  class EspaciospartController < Msip::Admin::BasicasController
    before_action :set_espaciopart,
      only: [:show, :edit, :update, :destroy]
    load_and_authorize_resource  class: ::Espaciopart

    def clase 
      "::Espaciopart"
    end

    def set_espaciopart
      @basica = Espaciopart.find(params[:id])
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

    def espaciopart_params
      params.require(:espaciopart).permit(*atributos_form)
    end

  end
end
