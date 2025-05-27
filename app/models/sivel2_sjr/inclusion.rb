# frozen_string_literal: true
module Sivel2Sjr
  # Inclusión en RUV
  class Inclusion < ActiveRecord::Base
    include Msip::Basica

    self.table_name = "sivel2_sjr_inclusion"

    has_many :desplazamiento, 
class_name: "Sivel2Sjr::Desplazamiento",, 
validate: true
  end
end
