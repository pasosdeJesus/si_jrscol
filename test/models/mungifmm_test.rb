require 'test_helper'

class MungifmmTest < ActiveSupport::TestCase

  PRUEBA_MUNGIFMM = {
    nombre: "Mungifmm",
    fechacreacion: "2021-11-04",
    created_at: "2021-11-04"
  }

  test "valido" do
    mungifmm = ::Mungifmm.create(
      PRUEBA_MUNGIFMM)
    assert(mungifmm.valid?)
    mungifmm.destroy
  end

  test "no valido" do
    mungifmm = ::Mungifmm.new(
      PRUEBA_MUNGIFMM)
    mungifmm.nombre = ''
    assert_not(mungifmm.valid?)
    mungifmm.destroy
  end

end
