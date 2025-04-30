require 'test_helper'

module Admin
  class DeclaracionesruvControllerTest < ActionController::TestCase
    include Devise::Test::ControllerHelpers

    setup do
      Rails.application.try(:reload_routes_unless_loaded)
      @current_usuario = ::Usuario.create(PRUEBA_USUARIO)
      sign_in @current_usuario
      @controller = Admin::DeclaracionesruvController.new
      @declaracionruv = Declaracionruv.create!(nombre: 'prueba', fechacreacion: '01-01-2021')
    end

    test "should get index" do
      get :index
      assert_response :success
    end

    test "should get new" do
      get :new
      assert_response :success
    end

    test "should create declaracionruv" do
      assert_difference('Declaracionruv.count') do
        post :create, params: { declaracionruv: { fechacreacion: '02-01-2021', nombre: 'prueba2'}}
      end

      assert_redirected_to admin_declaracionruv_path(assigns(:declaracionruv))
    end

    test "should show declaracionruv" do
      get :show, params: {id: @declaracionruv}
      assert_response :success
    end

    test "should get edit" do
      get :edit, params: {id: @declaracionruv}
      assert_response :success
    end

    test "should update declaracionruv" do
      patch :update, params: {id: @declaracionruv, declaracionruv: { created_at: @declaracionruv.created_at, fechacreacion: @declaracionruv.fechacreacion, fechadeshabilitacion: @declaracionruv.fechadeshabilitacion, nombre: @declaracionruv.nombre, observaciones: @declaracionruv.observaciones, updated_at: @declaracionruv.updated_at }}
      assert_redirected_to admin_declaracionruv_path(assigns(:declaracionruv))
    end

    test "should destroy declaracionruv" do
      assert_difference('Declaracionruv.count', -1) do
        delete :destroy, params: {id: @declaracionruv}
      end

      assert_redirected_to admin_declaracionesruv_path
    end
  end
end
