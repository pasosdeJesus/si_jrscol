# frozen_string_literal: true

require "cor1440_gen/concerns/models/proyecto"

module Cor1440Gen
  # Tabla básica área de actividad
  class Proyecto < ActiveRecord::Base
    include Cor1440Gen::Concerns::Models::Proyecto
  end
end
