# frozen_string_literal: true

require "test_helper"

class DocidsecundarioTest < ActiveSupport::TestCase
  test "valido" do
    persona = Msip::Persona.create(PRUEBA_PERSONA)

    assert persona.valid?
    # puts persona.valid?
    # puts persona.errors.full_messages.join('. ')
    tdocumento = Msip::Tdocumento.create(PRUEBA_TDOCUMENTO)

    assert tdocumento.valid?

    docidsecundario = ::Docidsecundario.create({
      persona_id: persona.id,
      tdocumento_id: tdocumento.id,
      numero: "123",
    })

    assert docidsecundario.valid?

    docidsecundario.destroy
    tdocumento.destroy
    persona.destroy
  end

  test "no valido" do
    docidsecundario = ::Docidsecundario.new

    assert_not docidsecundario.valid?
  end
end
