# frozen_string_literal: true

require "cor1440_gen/concerns/controllers/actividadespf_proyectofinanciero_controller"

module Cor1440Gen
  class ActividadespfProyectofinancieroController < ApplicationController
    before_action :preparar_actividadpf_proyectofinanciero
    load_and_authorize_resource class: Cor1440Gen::Actividadpf

    include Cor1440Gen::Concerns::Controllers::ActividadespfProyectofinancieroController


    private

    def preparar_actividadpf_proyectofinanciero
      r = Cor1440Gen::Actividadpf.new
      @registro = @proyectofinanciero =
        Cor1440Gen::Proyectofinanciero.new(
          actividadpf: [r],
        )
      @col_resultados = Cor1440Gen::ProyectosfinancierosController.
        ini_resultados(+params[:proyectofinanciero][:id])
      @indicadoresgifmm = Indicadorgifmm.habilitados
    end
  end
end
