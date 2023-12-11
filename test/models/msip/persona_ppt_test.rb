# frozen_string_literal: true

require_relative "../../test_helper"

module Msip
  class PersonaPptTest < ActiveSupport::TestCase

    test "persona nueva como primario" do
      persona = Persona.new(PRUEBA_PERSONA.merge(tdocumento_id: nil))

      assert_nil  persona.ppt

      persona.ppt = 1

      assert_equal 1, persona.numerodocumento.to_i
      assert_equal 16, persona.tdocumento_id
      assert_equal 1, persona.ppt.to_i

      persona.save

      assert_equal 1, persona.numerodocumento.to_i
      assert_equal 16, persona.tdocumento_id
      assert_equal 1, persona.ppt.to_i

      persona.destroy
    end


    test "con secundario" do
      persona = Persona.create(PRUEBA_PERSONA)
      assert_nil persona.ppt

      persona.ppt = 1
      persona.save

      assert_equal 1, 
        persona.docidsecundario.where(tdocumento_id: 16).take.numero.to_i
      assert_equal 1, persona.ppt.to_i
      persona.destroy
    end

    test "con secundario de persona no guardada" do
      persona = Persona.new(PRUEBA_PERSONA)
      assert_nil persona.ppt

      persona.ppt = 1
      persona.save

      assert_equal 1, 
        persona.docidsecundario.where(tdocumento_id: 16).take.numero.to_i
      assert_equal 1, persona.ppt.to_i
      persona.destroy
    end


  end
end
