require 'test_helper'

class MiembrofamiliarTest < ActiveSupport::TestCase

  PRUEBA_MIEMBROFAMILIAR = {
    nombre: "Miembrofamiliar",
    fechacreacion: "2020-08-07",
    created_at: "2020-08-07"
  }

  test "valido" do
    miembrofamiliar = ::Miembrofamiliar.create(
      PRUEBA_MIEMBROFAMILIAR)
    assert(miembrofamiliar.valid?)
    miembrofamiliar.destroy
  end

  test "no valido" do
    miembrofamiliar = ::Miembrofamiliar.new(
      PRUEBA_MIEMBROFAMILIAR)
    miembrofamiliar.nombre = ''
    assert_not(miembrofamiliar.valid?)
    miembrofamiliar.destroy
  end

  test "existente" do
    miembrofamiliar = ::Miembrofamiliar.where(id: 1).take
    assert_equal(miembrofamiliar.nombre, "Pareja sentimental")
  end

end
