require 'test_helper'

module Admin
  class TipostransferenciaControllerTest < ActionController::TestCase
    include Devise::Test::ControllerHelpers

    setup do
      Rails.application.try(:reload_routes_unless_loaded)
      @current_usuario = ::Usuario.create(PRUEBA_USUARIO)
      sign_in @current_usuario
      @controller = Admin::TipostransferenciaController.new
      @tipotransferencia = Tipotransferencia.create!(nombre: 'prueba', fechacreacion: '01-01-2021')
    end

    test "should get index" do
      get :index
      assert_response :success
    end

    test "should get new" do
      get :new
      assert_response :success
    end

    test "should create tipotransferencia" do
      assert_difference('Tipotransferencia.count') do
        post :create, params: { tipotransferencia: { fechacreacion: '02-01-2021', nombre: 'prueba2'}}
      end

      assert_redirected_to admin_tipotransferencia_path(assigns(:tipotransferencia))
    end

    test "should show tipotransferencia" do
      get :show, params: {id: @tipotransferencia}
      assert_response :success
    end

    test "should get edit" do
      get :edit, params: {id: @tipotransferencia}
      assert_response :success
    end

    test "should update tipotransferencia" do
      patch :update, params: {id: @tipotransferencia, tipotransferencia: { created_at: @tipotransferencia.created_at, fechacreacion: @tipotransferencia.fechacreacion, fechadeshabilitacion: @tipotransferencia.fechadeshabilitacion, nombre: @tipotransferencia.nombre, observaciones: @tipotransferencia.observaciones, updated_at: @tipotransferencia.updated_at }}
      assert_redirected_to admin_tipotransferencia_path(assigns(:tipotransferencia))
    end

    test "should destroy tipotransferencia" do
      assert_difference('Tipotransferencia.count', -1) do
        delete :destroy, params: {id: @tipotransferencia}
      end

      assert_redirected_to admin_tipostransferencia_path
    end
  end
end
