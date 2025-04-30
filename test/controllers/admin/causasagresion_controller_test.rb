require 'test_helper'

module Admin
  class CausasagresionControllerTest < ActionController::TestCase
    include Devise::Test::ControllerHelpers

    setup do
      Rails.application.try(:reload_routes_unless_loaded)
      @current_usuario = ::Usuario.create(PRUEBA_USUARIO)
      sign_in @current_usuario
      @controller = Admin::CausasagresionController.new
      @causaagresion = Causaagresion.create!(nombre: 'prueba', fechacreacion: '01-01-2021')
    end

    test "should get index" do
      get :index
      assert_response :success
    end

    test "should get new" do
      get :new
      assert_response :success
    end

    test "should create causaagresion" do
      assert_difference('Causaagresion.count') do
        post :create, params: { causaagresion: { fechacreacion: '02-01-2021', nombre: 'prueba2'}}
      end

      assert_redirected_to admin_causaagresion_path(assigns(:causaagresion))
    end

    test "should show causaagresion" do
      get :show, params: {id: @causaagresion}
      assert_response :success
    end

    test "should get edit" do
      get :edit, params: {id: @causaagresion}
      assert_response :success
    end

    test "should update causaagresion" do
      patch :update, params: {id: @causaagresion, causaagresion: { created_at: @causaagresion.created_at, fechacreacion: @causaagresion.fechacreacion, fechadeshabilitacion: @causaagresion.fechadeshabilitacion, nombre: @causaagresion.nombre, observaciones: @causaagresion.observaciones, updated_at: @causaagresion.updated_at }}
      assert_redirected_to admin_causaagresion_path(assigns(:causaagresion))
    end

    test "should destroy causaagresion" do
      assert_difference('Causaagresion.count', -1) do
        delete :destroy, params: {id: @causaagresion}
      end

      assert_redirected_to admin_causasagresion_path
    end
  end
end
