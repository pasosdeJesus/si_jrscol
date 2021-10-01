# encoding: UTF-8

require 'test_helper'

class MigracontactopreTest < ActiveSupport::TestCase

  PRUEBA_MIGRACONTACTOPRE = {
    nombre: "Migracontactopre",
    fechacreacion: "2020-07-12",
    created_at: "2020-07-12"
  }

  test "migracontactopre valido" do
    migracontactopre = ::Migracontactopre.create(
      PRUEBA_MIGRACONTACTOPRE)
    assert(migracontactopre.valid?)
    migracontactopre.destroy
  end

  test "migraconactopre no valido" do
    migracontactopre = ::Migracontactopre.new(
      PRUEBA_MIGRACONTACTOPRE)
    migracontactopre.nombre = ''
    assert_not(migracontactopre.valid?)
    migracontactopre.destroy
  end

  test "migracontacto existente" do
    migracontactopre = ::Migracontactopre.where(id: 1).take
    assert_equal(migracontactopre.nombre, "AMIGO")
  end

end
