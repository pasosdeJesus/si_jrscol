require 'test_helper'

module Sip
  class TdocumentoTest < ActiveSupport::TestCase
  
      PRUEBA_TDOCUMENTO = {
        id: 99,
        nombre: "Tdocumento_prueba",
        sigla: "td",
        ayuda: 'ayuda',
        formatoregex: "regex",
        observaciones: "obs",
        fechacreacion: "2018-10-25",
        created_at: "2018-10-25",
        updated_at: "2018-10-25"
      }
  
      test "valido" do
        tdocumento = Sip::Tdocumento.create(
          PRUEBA_TDOCUMENTO)
        assert(tdocumento.valid?)
        tdocumento.destroy
      end
  
      test "no valido" do
        tdocumento = Sip::Tdocumento.new(
          PRUEBA_TDOCUMENTO)
        tdocumento.nombre = ''
        assert_not(tdocumento.valid?)
        tdocumento.destroy
      end
  end
end
