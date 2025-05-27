# frozen_string_literal: true

require "test_helper"

module Admin
  class DificultadesmigracionControllerTest < ActionController::TestCase
    include Devise::Test::ControllerHelpers

    setup do
      Rails.application.try(:reload_routes_unless_loaded)
      @current_usuario = ::Usuario.create(PRUEBA_USUARIO)
      sign_in @current_usuario
      @controller = Admin::DificultadesmigracionController.new
      @dificultadmigracion = Dificultadmigracion.create!(nombre: "prueba", fechacreacion: "01-01-2021")
    end

    test "should get index" do
      get :index

      assert_response :success
    end

    test "should get new" do
      get :new

      assert_response :success
    end

    test "should create dificultadmigracion" do
      assert_difference("Dificultadmigracion.count") do
        post :create, params: { dificultadmigracion: { fechacreacion: "02-01-2021", nombre: "prueba2" } }
      end

      assert_redirected_to admin_dificultadmigracion_path(assigns(:dificultadmigracion))
    end

    test "should show dificultadmigracion" do
      get :show, params: { id: @dificultadmigracion }

      assert_response :success
    end

    test "should get edit" do
      get :edit, params: { id: @dificultadmigracion }

      assert_response :success
    end

    test "should update dificultadmigracion" do
      patch :update, params: { id: @dificultadmigracion, dificultadmigracion: { created_at: @dificultadmigracion.created_at, fechacreacion: @dificultadmigracion.fechacreacion, fechadeshabilitacion: @dificultadmigracion.fechadeshabilitacion, nombre: @dificultadmigracion.nombre, observaciones: @dificultadmigracion.observaciones, updated_at: @dificultadmigracion.updated_at } }

      assert_redirected_to admin_dificultadmigracion_path(assigns(:dificultadmigracion))
    end

    test "should destroy dificultadmigracion" do
      assert_difference("Dificultadmigracion.count", -1) do
        delete :destroy, params: { id: @dificultadmigracion }
      end

      assert_redirected_to admin_dificultadesmigracion_path
    end
  end
end
