# frozen_string_literal: true

require "msip/concerns/models/oficina"

module Msip
  class Oficina < ActiveRecord::Base
    include Msip::Concerns::Models::Oficina

    belongs_to :centropoblado,
      class_name: "Msip::Centropoblado",
      optional: true
    belongs_to :departamento,
      class_name: "Msip::Departamento",
      optional: true
    belongs_to :municipio,
      class_name: "Msip::Municipio",
      optional: true
    belongs_to :pais,
      class_name: "Msip::Pais",
      optional: true

    belongs_to :territorial

    has_many :casosjr,
      class_name: "Sivel2Sjr::Casosjr",
      validate: true

    has_and_belongs_to_many :proyectofinanciero,
      class_name: "Cor1440Gen::Proyectofinanciero",
      validate: true,
      association_foreign_key: "proyectofinanciero_id",
      join_table: "sivel2_sjr_oficina_proyectofinanciero"

    scope :filtro_territorial_id, lambda { |tid|
      where(territorial_id: tid)
    }
  end
end
