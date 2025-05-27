# frozen_string_literal: true

require "test_helper"

module Admin
  class FrecuenciasentregaControllerTest < ActionController::TestCase
    include Devise::Test::ControllerHelpers

    setup do
      @current_usuario = ::Usuario.create(PRUEBA_USUARIO)
      sign_in @current_usuario
      @controller = Admin::FrecuenciasentregaController.new
      @frecuenciaentrega = Frecuenciaentrega.create!(nombre: "prueba", fechacreacion: "01-01-2021")
    end

    test "should get index" do
      get :index

      assert_response :success
    end

    test "should get new" do
      get :new

      assert_response :success
    end

    test "should create frecuenciaentrega" do
      assert_difference("Frecuenciaentrega.count") do
        post :create, params: { frecuenciaentrega: { fechacreacion: "02-01-2021", nombre: "prueba2" } }
      end

      assert_redirected_to admin_frecuenciaentrega_path(assigns(:frecuenciaentrega))
    end

    test "should show frecuenciaentrega" do
      get :show, params: { id: @frecuenciaentrega }

      assert_response :success
    end

    test "should get edit" do
      get :edit, params: { id: @frecuenciaentrega }

      assert_response :success
    end

    test "should update frecuenciaentrega" do
      patch :update, params: { id: @frecuenciaentrega, frecuenciaentrega: { created_at: @frecuenciaentrega.created_at, fechacreacion: @frecuenciaentrega.fechacreacion, fechadeshabilitacion: @frecuenciaentrega.fechadeshabilitacion, nombre: @frecuenciaentrega.nombre, observaciones: @frecuenciaentrega.observaciones, updated_at: @frecuenciaentrega.updated_at } }

      assert_redirected_to admin_frecuenciaentrega_path(assigns(:frecuenciaentrega))
    end

    test "should destroy frecuenciaentrega" do
      assert_difference("Frecuenciaentrega.count", -1) do
        delete :destroy, params: { id: @frecuenciaentrega }
      end

      assert_redirected_to admin_frecuenciasentrega_path
    end
  end
end
