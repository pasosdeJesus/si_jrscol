require 'test_helper'

class DetallefinancieroPersonaTest < ActiveSupport::TestCase

  PRUEBA_DETALLEFINANCIEROPER = {
    persona_id: 1,
    detallefinanciero_id: 1
  }

  test "valido" do
    detallefinancieropersona = ::DetallefinancieroPersona.new(
      PRUEBA_DETALLEFINANCIEROPER)
    assert(detallefinancieropersona.valid?)
    detallefinancieropersona.destroy
  end

end
