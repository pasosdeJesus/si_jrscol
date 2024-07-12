require_dependency "cor1440_gen/concerns/controllers/financiadores_controller"

module Cor1440Gen
  module Admin
    class FinanciadoresController < Msip::Admin::BasicasController
      include Cor1440Gen::Concerns::Controllers::FinanciadoresController
      before_action :set_financiador, 
        only: [:show, :edit, :update, :destroy]
      load_and_authorize_resource  class: Cor1440Gen::Financiador

      def atributos_index
        [
          :id,
          :nombre,
          :nombregifmm,
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

    end
  end
end
