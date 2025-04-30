require 'test_helper'

module Admin
  class TrivalentespositivaControllerTest < ActionController::TestCase
    include Devise::Test::ControllerHelpers

    setup do
      Rails.application.try(:reload_routes_unless_loaded)
      @current_usuario = ::Usuario.create(PRUEBA_USUARIO)
      sign_in @current_usuario
      @controller = Admin::TrivalentespositivaController.new
      @trivalentepositiva = Trivalentepositiva.create!(nombre: 'prueba', fechacreacion: '01-01-2021')
    end

    test "should get index" do
      get :index
      assert_response :success
    end

    test "should get new" do
      get :new
      assert_response :success
    end

    test "should create trivalentepositiva" do
      assert_difference('Trivalentepositiva.count') do
        post :create, params: { trivalentepositiva: { fechacreacion: '02-01-2021', nombre: 'prueba2'}}
      end

      assert_redirected_to admin_trivalentepositiva_path(assigns(:trivalentepositiva))
    end

    test "should show trivalentepositiva" do
      get :show, params: {id: @trivalentepositiva}
      assert_response :success
    end

    test "should get edit" do
      get :edit, params: {id: @trivalentepositiva}
      assert_response :success
    end

    test "should update trivalentepositiva" do
      patch :update, params: {id: @trivalentepositiva, trivalentepositiva: { created_at: @trivalentepositiva.created_at, fechacreacion: @trivalentepositiva.fechacreacion, fechadeshabilitacion: @trivalentepositiva.fechadeshabilitacion, nombre: @trivalentepositiva.nombre, observaciones: @trivalentepositiva.observaciones, updated_at: @trivalentepositiva.updated_at }}
      assert_redirected_to admin_trivalentepositiva_path(assigns(:trivalentepositiva))
    end

    test "should destroy trivalentepositiva" do
      assert_difference('Trivalentepositiva.count', -1) do
        delete :destroy, params: {id: @trivalentepositiva}
      end

      assert_redirected_to admin_trivalentespositiva_path
    end
  end
end
