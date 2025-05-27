# frozen_string_literal: true

require "test_helper"

module Admin
  class TiposproteccionControllerTest < ActionController::TestCase
    include Devise::Test::ControllerHelpers

    setup do
      @current_usuario = ::Usuario.create(PRUEBA_USUARIO)
      sign_in @current_usuario
      @controller = Admin::TiposproteccionController.new
      @tipoproteccion = Tipoproteccion.create!(nombre: "prueba", fechacreacion: "01-01-2021")
    end

    test "should get index" do
      get :index

      assert_response :success
    end

    test "should get new" do
      get :new

      assert_response :success
    end

    test "should create tipoproteccion" do
      assert_difference("Tipoproteccion.count") do
        post :create, params: { tipoproteccion: { fechacreacion: "02-01-2021", nombre: "prueba2" } }
      end

      assert_redirected_to admin_tipoproteccion_path(assigns(:tipoproteccion))
    end

    test "should show tipoproteccion" do
      get :show, params: { id: @tipoproteccion }

      assert_response :success
    end

    test "should get edit" do
      get :edit, params: { id: @tipoproteccion }

      assert_response :success
    end

    test "should update tipoproteccion" do
      patch :update, params: { id: @tipoproteccion, tipoproteccion: { created_at: @tipoproteccion.created_at, fechacreacion: @tipoproteccion.fechacreacion, fechadeshabilitacion: @tipoproteccion.fechadeshabilitacion, nombre: @tipoproteccion.nombre, observaciones: @tipoproteccion.observaciones, updated_at: @tipoproteccion.updated_at } }

      assert_redirected_to admin_tipoproteccion_path(assigns(:tipoproteccion))
    end

    test "should destroy tipoproteccion" do
      assert_difference("Tipoproteccion.count", -1) do
        delete :destroy, params: { id: @tipoproteccion }
      end

      assert_redirected_to admin_tiposproteccion_path
    end
  end
end
