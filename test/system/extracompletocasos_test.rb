require 'application_system_test_case'

class ExtracompletocasosTest < ApplicationSystemTestCase

  self.use_transactional_tests = false
  # Buscando evitar el error:
  # ActiveRecord::StatementInvalid: PG::InFailedSqlTransaction: ERROR:  current
  # transaction is aborted, commands ignored until end of transaction block
  #
  # El compromiso es que la prueba elimine los datos que cree

  setup do
    @usuario = Usuario.find_by(nusuario: 'sjrcol')
    @usuario.password = 'sjrcol123'
    visit new_usuario_session_path 
    fill_in "Usuario", with: @usuario.nusuario
    fill_in "Clave", with: @usuario.password
    click_button "Iniciar Sesión"
    assert page.has_content?("Administrar")


    # Creamos caso 
    #visit '/casos/nuevo'
    #@numcaso=find_field('Código').value

    #cs = Sivel2Sjr::Casosjr.where(id_caso: @numcaso).take
    #p = cs.contacto
    #p.nombres = 'Juan'
    #p.apellidos = 'Perez'
    #p.save!
  end

  test "genera con usuario administrador en base inicial" do
    assert page.has_content?("Casos")
    click_on "Casos"
    assert page.has_content?("Listado")
    click_on "Listado"
    assert page.has_content?("Búsqueda Avanzada")
    click_on "Búsqueda Avanzada"
    assert page.has_content?("Fecha de ingreso")

  end

end

