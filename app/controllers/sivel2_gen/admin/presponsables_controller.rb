require 'sivel2_gen/concerns/controllers/presponsables_controller'

module Sivel2Gen
  module Admin
    class PresponsablesController < Msip::Admin::BasicasController
      before_action :set_presponsable, only: [:show, :edit, :update, :destroy]
      load_and_authorize_resource class: Sivel2Gen::Presponsable

      include Sivel2Gen::Concerns::Controllers::PresponsablesController

      def atributos_index
        [
          :id, 
          :nombre,
          :papa,
          :observaciones,
          :nombre_res1612,
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

    end
  end
end
