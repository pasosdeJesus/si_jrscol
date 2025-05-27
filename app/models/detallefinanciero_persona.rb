# frozen_string_literal: true

# Relación n:n entre detalle financiero y persona.
# Permite especificar una o más personas a un detalle financiero.
class DetallefinancieroPersona < ActiveRecord::Base
  belongs_to :detallefinanciero,
    class_name: "::Detallefinanciero"

  belongs_to :persona,
    class_name: "Msip::Persona"
end
