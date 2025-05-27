# frozen_string_literal: true

require "cor1440_gen/concerns/models/financiador"

module Cor1440Gen
  class Financiador < ActiveRecord::Base
    include Msip::Basica

    validates :nombregifmm, length: { in: 0..256 }
  end
end
