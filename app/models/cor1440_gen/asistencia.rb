# frozen_string_literal: true

require "cor1440_gen/concerns/models/asistencia"

module Cor1440Gen
  class Asistencia < ActiveRecord::Base
    include Cor1440Gen::Concerns::Models::Asistencia


    belongs_to :perfilorgsocial,
      class_name: "Msip::Perfilorgsocial",
      optional: false

    validates :perfilorgsocial, presence: true
  end
end
