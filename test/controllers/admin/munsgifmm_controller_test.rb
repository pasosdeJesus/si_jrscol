require 'test_helper'

module Admin
  class MunsgifmmControllerTest < ActionController::TestCase
    include Devise::Test::ControllerHelpers

    setup do
      Rails.application.try(:reload_routes_unless_loaded)

      @current_usuario = ::Usuario.create(PRUEBA_USUARIO)
      sign_in @current_usuario
      @controller = Admin::MunsgifmmController.new
      @mungifmm = Mungifmm.create!(nombre: 'prueba', fechacreacion: '01-01-2021')
    end

    test "should get index" do
      get :index
      assert_response :success
    end

    test "should get new" do
      get :new
      assert_response :success
    end

    test "should create mungifmm" do
      assert_difference('Mungifmm.count') do
        post :create, params: { mungifmm: { fechacreacion: '02-01-2021', nombre: 'prueba2'}}
      end

      assert_redirected_to admin_mungifmm_path(assigns(:mungifmm))
    end

    test "should show mungifmm" do
      get :show, params: {id: @mungifmm}
      assert_response :success
    end

    test "should get edit" do
      get :edit, params: {id: @mungifmm}
      assert_response :success
    end

    test "should update mungifmm" do
      patch :update, params: {id: @mungifmm, mungifmm: { created_at: @mungifmm.created_at, fechacreacion: @mungifmm.fechacreacion, fechadeshabilitacion: @mungifmm.fechadeshabilitacion, nombre: @mungifmm.nombre, observaciones: @mungifmm.observaciones, updated_at: @mungifmm.updated_at }}
      assert_redirected_to admin_mungifmm_path(assigns(:mungifmm))
    end

    test "should destroy mungifmm" do
      assert_difference('Mungifmm.count', -1) do
        delete :destroy, params: {id: @mungifmm}
      end

      assert_redirected_to admin_munsgifmm_path

    end
  end
end
