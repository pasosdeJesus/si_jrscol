# frozen_string_literal: true

require "sivel2_gen/concerns/models/anexo"

module Msip
  class Anexo < ActiveRecord::Base
    include Sivel2Gen::Concerns::Models::Anexo

    has_many :anexo_victima,
      validate: true,
      class_name: "Sivel2Gen::AnexoVictima"
    has_many :victima,
      class_name: "Sivel2Gen::Victima",
      through: :anexo_victima
  end
end
