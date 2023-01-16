require_relative '../../test_helper'

module Sivel2Sjr
  class DesplazamientoTest < ActiveSupport::TestCase

    PRUEBA_CASO= {
      titulo: "ejemplo",
      fecha: "2021-04-14",
      memo: "Desplazamiento",
      created_at: "2021-04-14",
    }

    PRUEBA_PERSONA = {
      nombres: "Juan",
      apellidos: "Perez",
      sexo: 'M',
      anionac: 1980,
      id_pais: 170,
      tdocumento_id: 1,
      numerodocumento: 4,
      created_at: "2021-04-14",
    }

    PRUEBA_CASOSJR = {
      id_caso: 0, # por llenar
      contacto_id: 0, # por llenar
      fecharec: "2021-04-14",
      asesor: 1,
      created_at: "2021-04-14",
    }
    
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
 
    PRUEBA_DESPLAZAMIENTO= {
      id_caso: 0, # por llenar
      fechaexpulsion: "2021-04-12",
      fechallegada: "2021-04-13",
      created_at: "2014-12-02",
    }

    test "valido" do
      caso = Sivel2Gen::Caso.create(PRUEBA_CASO)
      assert caso.valid?
      persona= Msip::Persona.create(PRUEBA_PERSONA)
      #puts persona.valid?
      #puts persona.errors.full_messages.join('. ')
      assert persona.valid?
      victima= Sivel2Gen::Victima.create({
        id_caso: caso.id,
        id_persona: persona.id
      })
      assert victima.valid?
      casosjr = Sivel2Sjr::Casosjr.create(PRUEBA_CASOSJR.merge(
        {id_caso: caso.id, contacto_id: persona.id}))
      assert casosjr.valid?
      u1 = Msip::Ubicacionpre.create(PRUEBA_UBICACIONPRE1)
      assert u1.valid?
      u2 = Msip::Ubicacionpre.create(PRUEBA_UBICACIONPRE2)
      assert u2.valid?

      desplazamiento = Desplazamiento.create(PRUEBA_DESPLAZAMIENTO.merge({ 
        id_caso: caso.id, 
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
