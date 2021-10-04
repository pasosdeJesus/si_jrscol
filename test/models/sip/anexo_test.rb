# encoding: UTF-8

require 'test_helper'

module Sip
  class AnexoTest < ActiveSupport::TestCase
  
      PRUEBA_ANEXO = {
        descripcion: "Descripción anexo",
        adjunto_file_name: "Nombre del anexo",
        adjunto_content_type: "image/png",
        adjunto_file_size: 71061,
        adjunto_updated_at: "2018-10-25",
        created_at: "2018-10-25",
      }
  
      test "valido" do
        anexo = Sip::Anexo.create(
          PRUEBA_ANEXO)
        assert(anexo.valid?)
        anexo.destroy
      end
  
      test "no valido" do
        anexo = Sip::Anexo.new(
          PRUEBA_ANEXO)
        anexo.adjunto_file_name = ''
        assert_not(anexo.valid?)
        anexo.destroy
      end
  
  end
end
