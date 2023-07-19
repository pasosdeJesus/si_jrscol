require 'test_helper'

# Esta prueba supone que en la tabla básica hay un registro con id 1
# Si no lo hay agregar skip a pruebas que lo suponen o crear registro
# con id 1 en las mismas o en setup

module Admin
  class ProductoslegControllerTest < ActionDispatch::IntegrationTest
    PRODUCTOLEG_NUEVA = {
      nombre: 'X',
      observaciones: 'y',
      fechacreacion: '2023-07-19',
      fechadeshabilitacion: nil,
      created_at: '2023-07-19',
      updated_at: '2023-07-19',
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
      get admin_productosleg_path
      assert_response :success
      assert_template :index
    end

    test "debe presentar resumen de existente" do
      get admin_productoleg_url(Productoleg.find(IDEX))
      assert_response :success
      assert_template :show
    end

    test "debe presentar formulario para nueva" do
      get new_admin_productoleg_path
      assert_response :success
      assert_template :new
    end

    test "debe crear nueva" do
      assert_difference('Productoleg.count') do
        post admin_productosleg_path, params: { 
          productoleg: PRODUCTOLEG_NUEVA
        }
      end

      assert_redirected_to admin_productoleg_path(
        assigns(:productoleg))
    end

    test "debe actualizar existente" do
      patch admin_productoleg_path(Productoleg.find(IDEX)),
        params: { productoleg: { nombre: 'YY'}}

      assert_redirected_to admin_productoleg_path(
        assigns(:productoleg))
    end

    test "debe eliminar" do
      r = Productoleg.create!(PRODUCTOLEG_NUEVO)
      assert_difference('Productoleg.count', -1) do
        delete admin_productoleg_url(Productoleg.find(r.id))
      end

      assert_redirected_to admin_productosleg_path
    end
  end
end
