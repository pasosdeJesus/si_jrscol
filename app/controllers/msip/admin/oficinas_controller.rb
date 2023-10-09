require 'msip/concerns/controllers/oficinas_controller'

module Msip
  module Admin
    class OficinasController < Msip::Admin::BasicasController

      before_action :set_oficina, only: [:show, :edit, :update, :destroy]
      load_and_authorize_resource class: Msip::Oficina

      include Msip::Concerns::Controllers::OficinasController

      def atributos_index
        [:id,
         :nombre,
         :observaciones,
         :pais_id,
         :departamento_id,
         :municipio_id,
         :clase_id,
         :fechacreacion_localizada,
         :habilitado
        ]
      end
  
    end
  end
end
