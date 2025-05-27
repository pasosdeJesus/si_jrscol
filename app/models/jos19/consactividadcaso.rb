# frozen_string_literal: true

require "jos19/concerns/models/consactividadcaso"

module Jos19
  class Consactividadcaso < ActiveRecord::Base
    include Jos19::Concerns::Models::Consactividadcaso

    belongs_to :victimasjr,
      class_name: "Sivel2Sjr::Victimasjr",
      foreign_key: "victima_id",
      optional: false
  end
end
