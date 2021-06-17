# encoding: UTF-8

require 'cor1440_gen/concerns/models/orgsocial'

module Sip
  class Orgsocial < ActiveRecord::Base
    include Cor1440Gen::Concerns::Models::Orgsocial
      belongs_to :departamento, class_name: "Sip::Departamento",
        foreign_key: "departamento_id", validate: true, optional: true
      belongs_to :lineaorgsocial, class_name: "Sip::Lineaorgsocial",
        foreign_key: "lineaorgsocial_id", validate: true, optional: true
      belongs_to :municipio, class_name: "Sip::Municipio",
        foreign_key: "municipio_id", validate: true, optional: true
      belongs_to :tipoorgsocial, class_name: "Sip::Tipoorgsocial",
        foreign_key: "tipoorgsocial_id", validate: true, optional: true

      validates :tipoorgsocial_id, presence: true
      validates :nit, uniqueness: true, allow_blank: true

      def presenta(atr)
        case atr.to_s
        when 'actualización'
          presenta_cor1440_gen('updated_at')
        when 'creación'
          presenta_cor1440_gen('created_at')
        when 'dirección'
          direccion ? direccion : ''
        when 'país'
          pais ? pais.nombre : ''
        when 'población_relacionada'
          presenta_cor1440_gen('sectores')
        when 'teléfono'
          telefono ? telefono : ''
        when 'tipo'
          tipoorgsocial ? tipoorgsocial.nombre : ''
        else
          presenta_cor1440_gen(atr)
        end
      end

  end
end
