require_relative '../../test_helper'

module Sivel2Sjr
  class CasosjrTest < ActiveSupport::TestCase

    test "valido" do
      caso = Sivel2Gen::Caso.create(PRUEBA_CASO)
      assert caso.valid?
      persona= Msip::Persona.create(PRUEBA_PERSONA)
      assert persona.valid?
      victima= Sivel2Gen::Victima.create({
        caso_id: caso.id,
        persona_id: persona.id
      })
      assert victima.valid?
      casosjr = Sivel2Sjr::Casosjr.create(PRUEBA_CASOSJR.merge(
        {caso_id: caso.id, contacto_id: persona.id}))
      assert casosjr.valid?

      assert_equal casosjr.oficina_id, 1
      assert_equal casosjr.territorial_id, 1

      casosjr.destroy
      victima.destroy
      persona.destroy
      caso.destroy
    end

    test "no valido" do
      casosjr = Sivel2Sjr::Casosjr.create(PRUEBA_CASOSJR)
      assert_not casosjr.valid?
      casosjr.destroy
    end


  end
end
