require 'test_helper'

class ProveedorTest < ActiveSupport::TestCase

  PRUEBA_PROVEEDOR = {
    nombre: "Proveedor",
    fechacreacion: "2023-06-22",
    created_at: "2023-06-22"
  }

  test "valido" do
    proveedor = ::Proveedor.create(
      PRUEBA_PROVEEDOR)
    assert(proveedor.valid?)
    proveedor.destroy
  end

  test "no valido" do
    proveedor = ::Proveedor.new(
      PRUEBA_PROVEEDOR)
    proveedor.nombre = ''
    assert_not(proveedor.valid?)
    proveedor.destroy
  end

  test "existente" do
    skip
    proveedor = ::Proveedor.where(id: 0).take
    assert_equal(proveedor.nombre, "SIN INFORMACIÓN")
  end

end
