# frozen_string_literal: true

require "test_helper"

module Admin
  class CausasmigracionControllerTest < ActionController::TestCase
    include Devise::Test::ControllerHelpers

    setup do
      @current_usuario = ::Usuario.create(PRUEBA_USUARIO)
      sign_in @current_usuario
      @controller = Admin::CausasmigracionController.new
      @causamigracion = Causamigracion.create!(nombre: "prueba", fechacreacion: "01-01-2021")
    end

    test "should get index" do
      get :index

      assert_response :success
    end

    test "should get new" do
      get :new

      assert_response :success
    end

    test "should create causamigracion" do
      assert_difference("Causamigracion.count") do
        post :create, params: { causamigracion: { fechacreacion: "02-01-2021", nombre: "prueba2" } }
      end

      assert_redirected_to admin_causamigracion_path(assigns(:causamigracion))
    end

    test "should show causamigracion" do
      get :show, params: { id: @causamigracion }

      assert_response :success
    end

    test "should get edit" do
      get :edit, params: { id: @causamigracion }

      assert_response :success
    end

    test "should update causamigracion" do
      patch :update, params: { id: @causamigracion, causamigracion: { created_at: @causamigracion.created_at, fechacreacion: @causamigracion.fechacreacion, fechadeshabilitacion: @causamigracion.fechadeshabilitacion, nombre: @causamigracion.nombre, observaciones: @causamigracion.observaciones, updated_at: @causamigracion.updated_at } }

      assert_redirected_to admin_causamigracion_path(assigns(:causamigracion))
    end

    test "should destroy causamigracion" do
      assert_difference("Causamigracion.count", -1) do
        delete :destroy, params: { id: @causamigracion }
      end

      assert_redirected_to admin_causasmigracion_path
    end
  end
end
