# encoding: UTF-8
require_dependency "sip/concerns/controllers/orgsociales_controller"

module Sip
  class OrgsocialesController < Heb412Gen::ModelosController
    include Sip::Concerns::Controllers::OrgsocialesController
    
    def atributos_index
      [ :id, 
        :grupoper_id,
        :tipoorgsocial_id,
        { :sectororgsocial_ids => [] },
        :lineaorgsocial_id,
        :email,
        :web,
        :telefono, 
        :fax,
        :pais,
        :departamento,
        :municipio,
        :direccion,
        :nit,
        :habilitado
      ]
    end

    def atributos_show
      atributos_index 
    end

    def atributos_form
      a = atributos_show - [
        :id, 
        :habilitado
      ] + [
        :fechadeshabilitacion_localizada
      ]
      a[a.index(:grupoper_id)] = :grupoper
      return a
    end

    def orgsocial_params
      params.require(:orgsocial).permit(
        atributos_form - [:grupoper] +
        [ :departamento_id,
          :municipio_id,
          :pais_id,
          :grupoper_attributes => [
            :id,
            :nombre,
            :anotaciones ]
      ]) 
    end

    def vistas_manejadas
      ['Orgsocial']
    end

  end
end
