# frozen_string_literal: true

require "test_helper"

module Admin
  class AgresionesmigracionControllerTest < ActionController::TestCase
    include Devise::Test::ControllerHelpers

    setup do
      Rails.application.try(:reload_routes_unless_loaded)
      @current_usuario = ::Usuario.create(PRUEBA_USUARIO)
      sign_in @current_usuario
      @controller = Admin::AgresionesmigracionController.new
      @agresionmigracion = Agresionmigracion.create!(nombre: "prueba", fechacreacion: "01-01-2021")
    end

    test "should get index" do
      get :index

      assert_response :success
    end

    test "should get new" do
      get :new

      assert_response :success
    end

    test "should create agresionmigracion" do
      assert_difference("Agresionmigracion.count") do
        post :create, params: { agresionmigracion: { fechacreacion: "02-01-2021", nombre: "prueba2" } }
      end
      assert_redirected_to admin_agresionmigracion_path(assigns(:agresionmigracion))
    end

    test "should show agresionmigracion" do
      get :show, params: { id: @agresionmigracion }

      assert_response :success
    end

    test "should get edit" do
      get :edit, params: { id: @agresionmigracion }

      assert_response :success
    end

    test "should update agresionmigracion" do
      patch :update, params: { id: @agresionmigracion, agresionmigracion: { created_at: @agresionmigracion.created_at, fechacreacion: @agresionmigracion.fechacreacion, fechadeshabilitacion: @agresionmigracion.fechadeshabilitacion, nombre: @agresionmigracion.nombre, observaciones: @agresionmigracion.observaciones, updated_at: @agresionmigracion.updated_at } }

      assert_redirected_to admin_agresionmigracion_path(assigns(:agresionmigracion))
    end

    test "should destroy agresionmigracion" do
      assert_difference("Agresionmigracion.count", -1) do
        delete :destroy, params: { id: @agresionmigracion }
      end

      assert_redirected_to admin_agresionesmigracion_path
    end
  end
end
