# frozen_string_literal: true

require "msip/concerns/models/ubicacionpre"

module Msip
  class Ubicacionpre < ActiveRecord::Base
    include Msip::Concerns::Models::Ubicacionpre

    has_many :expulsion,
      class_name: "Sivel2Sjr::Desplazamiento",
      foreign_key: "expulsionubicacionpre_id",
      validate: true,
      dependent: :destroy
    has_many :llegada,
      class_name: "Sivel2Sjr::Desplazamiento",
      foreign_key: "llegadaubicacionpre_id",
      validate: true,
      dependent: :destroy
  end
end
