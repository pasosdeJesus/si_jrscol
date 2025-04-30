require 'test_helper'

module Admin
  class PerfilesmigracionControllerTest < ActionController::TestCase
    include Devise::Test::ControllerHelpers

    setup do
      Rails.application.try(:reload_routes_unless_loaded)

      @current_usuario = ::Usuario.create(PRUEBA_USUARIO)
      sign_in @current_usuario
      @controller = Admin::PerfilesmigracionController.new
      @perfilmigracion = Perfilmigracion.create!(nombre: 'prueba', fechacreacion: '01-01-2021')
    end

    test "should get index" do
      get :index
      assert_response :success
    end

    test "should get new" do
      get :new
      assert_response :success
    end

    test "should create perfilmigracion" do
      assert_difference('Perfilmigracion.count') do
        post :create, params: { perfilmigracion: { fechacreacion: '01-01-2021', nombre: 'prueba2' }}
      end

      assert_redirected_to admin_perfilmigracion_path(assigns(:perfilmigracion))

    end

    test "should show perfilmigracion" do
      get :show, params: { id: @perfilmigracion}
      assert_response :success
    end

    test "should get edit" do
      get :edit, params:{ id: @perfilmigracion}
      assert_response :success
    end

    test "should update perfilmigracion" do
      patch :update, params:{ id: @perfilmigracion, perfilmigracion: { created_at: @perfilmigracion.created_at, fechacreacion: @perfilmigracion.fechacreacion, fechadeshabilitacion: @perfilmigracion.fechadeshabilitacion, nombre: @perfilmigracion.nombre, observaciones: @perfilmigracion.observaciones, updated_at: @perfilmigracion.updated_at }}
      assert_redirected_to admin_perfilmigracion_path(assigns(:perfilmigracion))
    end

    test "should destroy perfilmigracion" do
      assert_difference('Perfilmigracion.count', -1) do
        delete :destroy, params:{ id: @perfilmigracion} 
      end

      assert_redirected_to admin_perfilesmigracion_path
    end
  end
end
