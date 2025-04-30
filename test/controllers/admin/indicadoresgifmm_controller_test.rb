require 'test_helper'

module Admin
  class IndicadoresgifmmControllerTest < ActionController::TestCase
    include Devise::Test::ControllerHelpers

    setup do
      Rails.application.try(:reload_routes_unless_loaded)
      @current_usuario = ::Usuario.create(PRUEBA_USUARIO)
      sign_in @current_usuario
      @controller = Admin::IndicadoresgifmmController.new
      @sectorgifmm = Sectorgifmm.create!(nombre: 'prueba', fechacreacion: '01-01-2021')
      @indicadorgifmm = Indicadorgifmm.create!(nombre: 'prueba', sectorgifmm_id: @sectorgifmm.id, fechacreacion: '01-01-2021')
    end

    test "should get index" do
      get :index
      assert_response :success
    end

    test "should get new" do
      get :new
      assert_response :success
    end

    test "should create indicadorgifmm" do
      assert_difference('Indicadorgifmm.count') do
        post :create, params: { indicadorgifmm: { fechacreacion: '02-01-2021', nombre: 'prueba2', sectorgifmm_id: @sectorgifmm.id}}
      end

      assert_redirected_to admin_indicadorgifmm_path(assigns(:indicadorgifmm))
    end

    test "should show indicadorgifmm" do
      get :show, params: {id: @indicadorgifmm}
      assert_response :success
    end

    test "should get edit" do
      get :edit, params: {id: @indicadorgifmm}
      assert_response :success
    end

    test "should update indicadorgifmm" do
      patch :update, params: {id: @indicadorgifmm, indicadorgifmm: { created_at: @indicadorgifmm.created_at, fechacreacion: @indicadorgifmm.fechacreacion, fechadeshabilitacion: @indicadorgifmm.fechadeshabilitacion, nombre: @indicadorgifmm.nombre, observaciones: @indicadorgifmm.observaciones, updated_at: @indicadorgifmm.updated_at }}
      assert_redirected_to admin_indicadorgifmm_path(assigns(:indicadorgifmm))
    end

    test "should destroy indicadorgifmm" do
      assert_difference('Indicadorgifmm.count', -1) do
        delete :destroy, params: {id: @indicadorgifmm}
      end

      assert_redirected_to admin_indicadoresgifmm_path
    end
  end
end
