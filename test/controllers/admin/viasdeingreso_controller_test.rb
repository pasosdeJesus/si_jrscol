require 'test_helper'

module Admin
  class ViasdeingresoControllerTest < ActionController::TestCase
    include Devise::Test::ControllerHelpers

    setup do
      @current_usuario = ::Usuario.create(PRUEBA_USUARIO)
      sign_in @current_usuario
      @controller = Admin::ViasdeingresoController.new
      @viadeingreso = Viadeingreso.create!(nombre: 'prueba', fechacreacion: '01-01-2021')
    end

    test "should get index" do
      get :index
      assert_response :success
    end

    test "should get new" do
      get :new
      assert_response :success
    end

    test "should create viadeingreso" do
      assert_difference('Viadeingreso.count') do
        post :create, params: { viadeingreso: { fechacreacion: '02-01-2021', nombre: 'prueba2'}}
      end

      assert_redirected_to admin_viadeingreso_path(assigns(:viadeingreso))
    end

    test "should show viadeingreso" do
      get :show, params: {id: @viadeingreso}
      assert_response :success
    end

    test "should get edit" do
      get :edit, params: {id: @viadeingreso}
      assert_response :success
    end

    test "should update viadeingreso" do
      patch :update, params: {id: @viadeingreso, viadeingreso: { created_at: @viadeingreso.created_at, fechacreacion: @viadeingreso.fechacreacion, fechadeshabilitacion: @viadeingreso.fechadeshabilitacion, nombre: @viadeingreso.nombre, observaciones: @viadeingreso.observaciones, updated_at: @viadeingreso.updated_at }}
      assert_redirected_to admin_viadeingreso_path(assigns(:viadeingreso))
    end

    test "should destroy viadeingreso" do
      assert_difference('Viadeingreso.count', -1) do
        delete :destroy, params: {id: @viadeingreso}
      end

      assert_redirected_to admin_viasdeingreso_path
    end
  end
end
