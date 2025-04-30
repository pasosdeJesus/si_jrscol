require 'test_helper'

module Admin
  class AccionesjuridicasControllerTest < ActionController::TestCase
    include Devise::Test::ControllerHelpers
    include Rails.application.routes.url_helpers

    setup do
      Rails.application.try(:reload_routes_unless_loaded)
      @current_usuario = ::Usuario.create(PRUEBA_USUARIO)
      sign_in @current_usuario
      @controller = Sivel2Sjr::Admin::AccionesjuridicasController.new
      @accionjuridica = Sivel2Sjr::Accionjuridica.create!(nombre: 'prueba', fechacreacion: '01-01-2021')
    end

    test "should get index" do
      get :index, params: { use_route: admin_accionesjuridicas_path }
      assert_response :success
    end

    test "should get new" do
      get :new, params: { use_route: admin_accionesjuridicas_path }
      assert_response :success
    end

    test "should create accionjuridica" do
      skip
      assert_difference('Sivel2Sjr::Accionjuridica.count') do
        post :create, params: {use_route: admin_accionesjuridicas_path, accionjuridica: { fechacreacion: '02-01-2021', nombre: 'prueba2'}}
      end

    end

    test "should show accionjuridica" do
      skip
      get :show, params: {use_route: admin_accionjuridica_path, id: @accionjuridica}
      assert_response :success
    end

    test "should get edit" do
      skip
      debugger
      get :edit, params: {use_route: admin_accionjuridica_path, id: @accionjuridica}
      assert_response :success
    end

    test "should update accionjuridica" do
      skip
      patch :update, params: {use_route: admin_accionjuridica_path, id: @accionjuridica, accionjuridica: { created_at: @accionjuridica.created_at, fechacreacion: @accionjuridica.fechacreacion, fechadeshabilitacion: @accionjuridica.fechadeshabilitacion, nombre: @accionjuridica.nombre, observaciones: @accionjuridica.observaciones, updated_at: @accionjuridica.updated_at }}
    end

    test "should destroy accionjuridica" do
      skip
      debugger
      assert_difference('Sivel2Sjr::Accionjuridica.count', -1) do
        delete :destroy, params: {use_route: admin_accionjuridica_path, id: @accionjuridica.id}
      end

    end
  end
end

