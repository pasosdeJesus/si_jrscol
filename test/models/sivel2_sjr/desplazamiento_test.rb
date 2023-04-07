require_relative '../../test_helper'

module Sivel2Sjr
  class DesplazamientoTest < ActiveSupport::TestCase

    PRUEBA_UBICACIONPRE1= {
      pais_id: 170,
      nombre: 'Colombia',
      created_at: "2021-04-14",
      updated_at: "2021-04-14"
    }

    PRUEBA_UBICACIONPRE2= {
      pais_id: 862,
      nombre: 'Venezuela',
      created_at: "2021-04-14",
      updated_at: "2021-04-14"
    }

    test "valido" do
      caso = Sivel2Gen::Caso.create(PRUEBA_CASO)
      assert caso.valid?
      persona= Msip::Persona.create(PRUEBA_PERSONA)
      #puts persona.valid?
      #puts persona.errors.full_messages.join('. ')
      assert persona.valid?
      victima= Sivel2Gen::Victima.create({
        caso_id: caso.id,
        persona_id: persona.id
      })
      assert victima.valid?
      casosjr = Sivel2Sjr::Casosjr.create(PRUEBA_CASOSJR.merge(
        {caso_id: caso.id, contacto_id: persona.id}))
      assert casosjr.valid?
      u1 = Msip::Ubicacionpre.create(PRUEBA_UBICACIONPRE1)
      assert u1.valid?
      u2 = Msip::Ubicacionpre.create(PRUEBA_UBICACIONPRE2)
      assert u2.valid?

      desplazamiento = Desplazamiento.create(PRUEBA_DESPLAZAMIENTO.merge({ 
        caso_id: caso.id, 
        expulsionubicacionpre_id: u1.id, 
        llegadaubicacionpre_id: u2.id, 
      }))

      assert desplazamiento.valid?
      desplazamiento.destroy
      u2.destroy
      u1.destroy
      casosjr.destroy
      victima.destroy
      persona.destroy
      caso.destroy
    end

    test "no valido" do
      desplazamiento = Desplazamiento.new PRUEBA_DESPLAZAMIENTO.merge({ 
        fechaexpulsion: nil 
      })
      assert_not desplazamiento.valid?
      desplazamiento.destroy
    end


  end
end
