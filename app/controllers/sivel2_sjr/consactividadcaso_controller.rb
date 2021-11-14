require 'sivel2_sjr/concerns/controllers/consactividadcaso_controller'

module Sivel2Sjr
  class ConsactividadcasoController < Heb412Gen::ModelosController


    load_and_authorize_resource class: Sivel2Sjr::Consactividadcaso
    include Sivel2Sjr::Concerns::Controllers::ConsactividadcasoController

    def atributos_index
      [:caso_id,
       :actividad_id,
       :actividad_fecha,
       :actividad_proyectofinanciero,
       :persona_nombres,
       :persona_apellidos,
       :persona_tipodocumento,
       :tipos_actividad
      ]
    end
  end
end
