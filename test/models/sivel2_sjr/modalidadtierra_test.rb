# frozen_string_literal: true

require_relative "../../test_helper"

module Sivel2Sjr
  class ModalidadtierraTest < ActiveSupport::TestCase
    PRUEBA_MODALIDADTIERRA = {
      nombre: "Acreditacion",
      fechacreacion: "2014-09-11",
      created_at: "2014-09-11",
    }

    test "valido" do
      modalidadtierra = Modalidadtierra.create(PRUEBA_MODALIDADTIERRA)

      assert modalidadtierra.valid?
      modalidadtierra.destroy
    end

    test "no valido" do
      modalidadtierra = Modalidadtierra.new(PRUEBA_MODALIDADTIERRA)
      modalidadtierra.nombre = ""

      assert_not modalidadtierra.valid?
      modalidadtierra.destroy
    end

    test "existente" do
      modalidadtierra = Sivel2Sjr::Modalidadtierra.find_by(id: 0)

      assert_equal "SIN INFORMACIÓN", modalidadtierra.nombre
    end
  end
end
