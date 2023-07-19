require 'test_helper'

class ProductolegTest < ActiveSupport::TestCase

  PRUEBA_PRODUCTOLEG = {
    nombre: "Productoleg",
    fechacreacion: "2023-07-19",
    created_at: "2023-07-19"
  }

  test "valido" do
    productoleg = ::Productoleg.create(
      PRUEBA_PRODUCTOLEG)
    assert(productoleg.valid?)
    productoleg.destroy
  end

  test "no valido" do
    productoleg = ::Productoleg.new(
      PRUEBA_PRODUCTOLEG)
    productoleg.nombre = ''
    assert_not(productoleg.valid?)
    productoleg.destroy
  end

  test "existente" do
    productoleg = ::Productoleg.where(id: 1).take
    assert_equal(productoleg.nombre, "ALIMENTOS")
  end

end
