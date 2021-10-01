# encoding: UTF-8

require 'test_helper'

module Sip
  class FuenteprensaTest < ActiveSupport::TestCase
  
      PRUEBA_FUENTEPRENSA = {
        nombre: "Fuenteprensa",
        fechacreacion: "2018-10-25",
        created_at: "2018-10-25",
      }
  
      test "valido" do
        fuenteprensa = Sip::Fuenteprensa.create(
          PRUEBA_FUENTEPRENSA)
        assert(fuenteprensa.valid?)
        fuenteprensa.destroy
      end
  
      test "no valido" do
        fuenteprensa = Sip::Fuenteprensa.new(
          PRUEBA_FUENTEPRENSA)
        fuenteprensa.nombre = ''
        assert_not(fuenteprensa.valid?)
        fuenteprensa.destroy
      end
  
  end
end
