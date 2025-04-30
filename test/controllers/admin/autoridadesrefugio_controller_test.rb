require 'test_helper'

module Admin
  class AutoridadesrefugioControllerTest < ActionController::TestCase
    include Devise::Test::ControllerHelpers

    setup do
      Rails.application.try(:reload_routes_unless_loaded)
      @current_usuario = ::Usuario.create(PRUEBA_USUARIO)
      sign_in @current_usuario
      @controller = Admin::AutoridadesrefugioController.new
      @autoridadrefugio = Autoridadrefugio.create!(nombre: 'prueba', fechacreacion: '01-01-2021')
    end

    test "should get index" do
      get :index
      assert_response :success
    end

    test "should get new" do
      get :new
      assert_response :success
    end

    test "should create autoridadrefugio" do
      assert_difference('Autoridadrefugio.count') do
        post :create, params: { autoridadrefugio: { fechacreacion: '01-01-2021', nombre: 'prueba3' }}
      end

      assert_redirected_to admin_autoridadrefugio_path(assigns(:autoridadrefugio))
    end

    test "should show autoridadrefugio" do
      get :show, params: { id: @autoridadrefugio}
      assert_response :success
    end

    test "should get edit" do
      get :edit, params: { id: @autoridadrefugio}
      assert_response :success
    end

    test "should update autoridadrefugio" do
      patch :update, params: { id: @autoridadrefugio, autoridadrefugio: { created_at: @autoridadrefugio.created_at, fechacreacion: @autoridadrefugio.fechacreacion, fechadeshabilitacion: @autoridadrefugio.fechadeshabilitacion, nombre: @autoridadrefugio.nombre, observaciones: @autoridadrefugio.observaciones, updated_at: @autoridadrefugio.updated_at }}
      assert_redirected_to admin_autoridadrefugio_path(assigns(:autoridadrefugio))
    end

    test "should destroy autoridadrefugio" do
      assert_difference('Autoridadrefugio.count', -1) do
        delete :destroy, params: { id: @autoridadrefugio}
      end

      assert_redirected_to admin_autoridadesrefugio_path
    end
  end
end
