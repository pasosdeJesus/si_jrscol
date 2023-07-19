require 'test_helper'

# Esta prueba supone que en la tabla básica hay un registro con id 1
# Si no lo hay agregar skip a pruebas que lo suponen o crear registro
# con id 1 en las mismas o en setup

module Admin
  class ProveedoresControllerTest < ActionDispatch::IntegrationTest
    PROVEEDOR_NUEVA = {
      nombre: 'X',
      observaciones: 'y',
      fechacreacion: '2023-06-22',
      fechadeshabilitacion: nil,
      created_at: '2023-06-22',
      updated_at: '2023-06-22',
    }

    IDEX = 10

    include Rails.application.routes.url_helpers
    include Devise::Test::IntegrationHelpers

    setup do
      @current_usuario = ::Usuario.find(1)
      sign_in @current_usuario
    end

    # Cada prueba se ejecuta en una transacción de la base de datos
    # que después de la prueba se revierte. Por lo que no
    # debe preocuparse por restaurar/borrar lo que modifique/elimine/agregue
    # en cada prueba.

    test "debe presentar listado" do
      get admin_proveedores_path
      assert_response :success
      assert_template :index
    end

    test "debe presentar resumen de existente" do
      get admin_proveedor_url(Proveedor.find(IDEX))
      assert_response :success
      assert_template :show
    end

    test "debe presentar formulario para nueva" do
      get new_admin_proveedor_path
      assert_response :success
      assert_template :new
    end

    test "debe crear nueva" do
      assert_difference('Proveedor.count') do
        post admin_proveedores_path, params: { 
          proveedor: PROVEEDOR_NUEVA
        }
      end

      assert_redirected_to admin_proveedor_path(
        assigns(:proveedor))
    end

    test "debe actualizar existente" do
      patch admin_proveedor_path(Proveedor.find(IDEX)),
        params: { proveedor: { nombre: 'YY'}}

      assert_redirected_to admin_proveedor_path(
        assigns(:proveedor))
    end

    test "debe eliminar" do
      r = Proveedor.create!(PROVEEDOR_NUEVO)
      assert_difference('Proveedor.count', -1) do
        delete admin_proveedor_url(Proveedor.find(r.id))
      end

      assert_redirected_to admin_proveedores_path
    end
  end
end
