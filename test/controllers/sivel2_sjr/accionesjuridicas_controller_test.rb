require 'test_helper'

module Sivel2Sjr
  class AccionesjuridicasControllerTest < ActionController::TestCase
    include Engine.routes.url_helpers
    include Devise::Test::ControllerHelpers
    include Rails.application.routes.url_helpers

    setup do
      @current_usuario = ::Usuario.create(PRUEBA_USUARIO)
      sign_in @current_usuario
      @controller = Sivel2Sjr::Admin::AccionesjuridicasController.new
      @accionjuridica = Accionjuridica.create!(nombre: 'prueba', fechacreacion: '01-01-2021')
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
      assert_difference('Accionjuridica.count') do
        post :create, params: {use_route: admin_accionesjuridicas_path, accionjuridica: { fechacreacion: '02-01-2021', nombre: 'prueba2'}}
      end

    end

    test "should show accionjuridica" do
      get :show, params: {use_route: admin_accionjuridica_path, id: @accionjuridica}
      assert_response :success
    end

    test "should get edit" do
      get :edit, params: {use_route: admin_accionjuridica_path, id: @accionjuridica}
      assert_response :success
    end

    test "should update accionjuridica" do
      patch :update, params: {use_route: admin_accionjuridica_path, id: @accionjuridica, accionjuridica: { created_at: @accionjuridica.created_at, fechacreacion: @accionjuridica.fechacreacion, fechadeshabilitacion: @accionjuridica.fechadeshabilitacion, nombre: @accionjuridica.nombre, observaciones: @accionjuridica.observaciones, updated_at: @accionjuridica.updated_at }}
    end

    test "should destroy accionjuridica" do
      assert_difference('Accionjuridica.count', -1) do
        delete :destroy, params: {use_route: admin_accionjuridica_path, id: @accionjuridica}
      end

    end
  end
end

