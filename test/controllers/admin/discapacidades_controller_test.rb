require 'test_helper'

module Admin
  class DiscapacidadesControllerTest < ActionController::TestCase
    include Devise::Test::ControllerHelpers

    setup do
      Rails.application.try(:reload_routes_unless_loaded)
      @current_usuario = ::Usuario.create(PRUEBA_USUARIO)
      sign_in @current_usuario
      @controller = Admin::DiscapacidadesController.new
      @discapacidad = Discapacidad.first
    end

    test "should get index" do
      get :index
      assert_response :success
    end

    test "should get new" do
      get :new
      assert_response :success
    end

    test "should create discapacidad" do
      assert_difference('Discapacidad.count') do
        post :create, params: { discapacidad: { fechacreacion: '01-01-2021', nombre: 'prueba', observaciones: 'prueba' }}
      end

      assert_redirected_to admin_discapacidad_path(assigns(:discapacidad))

    end

    test "should show discapacidad" do
      get :show, params: { id: @discapacidad}
      assert_response :success
    end

    test "should get edit" do
      get :edit, params:{ id: @discapacidad}
      assert_response :success
    end

    test "should update discapacidad" do
      patch :update, params:{ id: @discapacidad, discapacidad: { created_at: @discapacidad.created_at, fechacreacion: @discapacidad.fechacreacion, fechadeshabilitacion: @discapacidad.fechadeshabilitacion, nombre: @discapacidad.nombre, observaciones: @discapacidad.observaciones, updated_at: @discapacidad.updated_at }}
      assert_redirected_to admin_discapacidad_path(assigns(:discapacidad))
    end

    test "should destroy discapacidad" do
      assert_difference('Discapacidad.count', -1) do
        delete :destroy, params:{ id: @discapacidad} 
      end

      assert_redirected_to admin_discapacidades_path
    end
  end
end
