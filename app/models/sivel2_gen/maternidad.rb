require 'sivel2_gen/concerns/models/maternidad'

module Sivel2Gen
  # Tabla básica Maternidad
  class Maternidad < ActiveRecord::Base

    include Sivel2Gen::Concerns::Models::Maternidad

    has_many :victimasjr, class_name: "Sivel2Sjr::Victimasjr", 
      foreign_key: "maternidad_id", validate: true
  end
end
