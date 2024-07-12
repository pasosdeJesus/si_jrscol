module Admin
  class DepsgifmmController < Msip::Admin::BasicasController
    before_action :set_depgifmm, 
      only: [:show, :edit, :update, :destroy]
    load_and_authorize_resource  class: ::Depgifmm

    def clase 
      "::Depgifmm"
    end

    def set_depgifmm
      @basica = Depgifmm.find(params[:id])
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

    def depgifmm_params
      params.require(:depgifmm).permit(*atributos_form)
    end

  end
end
