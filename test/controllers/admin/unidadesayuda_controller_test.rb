# frozen_string_literal: true

require "test_helper"

module Admin
  class UnidadesayudaControllerTest < ActionController::TestCase
    include Devise::Test::ControllerHelpers

    setup do
      @current_usuario = ::Usuario.create(PRUEBA_USUARIO)
      sign_in @current_usuario
      @controller = Admin::UnidadesayudaController.new
      @unidadayuda = Unidadayuda.create!(nombre: "prueba", fechacreacion: "01-01-2021")
    end

    test "should get index" do
      get :index

      assert_response :success
    end

    test "should get new" do
      get :new

      assert_response :success
    end

    test "should create unidadayuda" do
      assert_difference("Unidadayuda.count") do
        post :create, params: { unidadayuda: { fechacreacion: "02-01-2021", nombre: "prueba2" } }
      end

      assert_redirected_to admin_unidadayuda_path(assigns(:unidadayuda))
    end

    test "should show unidadayuda" do
      get :show, params: { id: @unidadayuda }

      assert_response :success
    end

    test "should get edit" do
      get :edit, params: { id: @unidadayuda }

      assert_response :success
    end

    test "should update unidadayuda" do
      patch :update, params: { id: @unidadayuda, unidadayuda: { created_at: @unidadayuda.created_at, fechacreacion: @unidadayuda.fechacreacion, fechadeshabilitacion: @unidadayuda.fechadeshabilitacion, nombre: @unidadayuda.nombre, observaciones: @unidadayuda.observaciones, updated_at: @unidadayuda.updated_at } }

      assert_redirected_to admin_unidadayuda_path(assigns(:unidadayuda))
    end

    test "should destroy unidadayuda" do
      assert_difference("Unidadayuda.count", -1) do
        delete :destroy, params: { id: @unidadayuda }
      end
      assert_redirected_to admin_unidadesayuda_path
    end
  end
end
