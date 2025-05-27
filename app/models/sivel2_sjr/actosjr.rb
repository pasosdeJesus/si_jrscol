# frozen_string_literal: true

module Sivel2Sjr
  # Acto de violencia antecedente a un desplazamiento
  class Actosjr < ActiveRecord::Base
    include Msip::Modelo

    self.table_name = "sivel2_sjr_actosjr"

    belongs_to :acto,
      class_name: "Sivel2Gen::Acto",
      inverse_of: :actosjr,
      dependent: :delete,
      optional: false
    belongs_to :desplazamiento,
      class_name: "Sivel2Sjr::Desplazamiento",
      optional: true
  end
end
