require 'sivel2_gen/concerns/controllers/categorias_controller'

module Sivel2Gen
  module Admin
    class CategoriasController < Msip::Admin::BasicasController
      load_and_authorize_resource class: Sivel2Gen::Categoria

      include Sivel2Gen::Concerns::Controllers::CategoriasController

      def atributos_index
        [
          :id,
          :nombre,
          :supracategoria_id,
          #:contadaen,
          :tipocat,
          #:pconsolidado_id,
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
