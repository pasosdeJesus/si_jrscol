# frozen_string_literal: true

module Cor1440Gen
  class Gastoaprobado < ActiveRecord::Base

    belongs_to :actividad,
      class_name: "Cor1440Gen::Actividad",
      optional: false
    belongs_to :actividadpf,
      class_name: "Cor1440Gen::Actividadpf",
      optional: false

    validates :valor, comparison: {greater_than: 0}

  end
end
