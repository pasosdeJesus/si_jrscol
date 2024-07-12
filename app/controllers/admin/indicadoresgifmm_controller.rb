module Admin
  class IndicadoresgifmmController < Msip::Admin::BasicasController
    before_action :set_indicadorgifmm, 
      only: [:show, :edit, :update, :destroy]
    load_and_authorize_resource  class: ::Indicadorgifmm

    def clase 
      "::Indicadorgifmm"
    end

    def set_indicadorgifmm
      @basica = Indicadorgifmm.find(params[:id])
    end

    def atributos_index
      [
        :id, 
        :nombre,
        :sectorgifmm_id, 
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

    def indicadorgifmm_params
      params.require(:indicadorgifmm).permit(*atributos_form)
    end

  end
end
