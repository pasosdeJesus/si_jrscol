require "application_system_test_case"

class IniciarSesionTest < ApplicationSystemTestCase

  test "iniciar sesión" do
    Msip::CapybaraHelper.iniciar_sesion(
      self, Rails.configuration.relative_url_root, 'sjrcol', 'sjrcol123')
  end

end
