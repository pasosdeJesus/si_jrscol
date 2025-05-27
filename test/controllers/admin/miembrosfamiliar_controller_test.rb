# frozen_string_literal: true

require "test_helper"

module Admin
  class MiembrosfamiliarControllerTest < ActionController::TestCase
    include Devise::Test::ControllerHelpers

    setup do
      @current_usuario = ::Usuario.create(PRUEBA_USUARIO)
      sign_in @current_usuario
      @controller = Admin::MiembrosfamiliarController.new
      @miembrofamiliar = Miembrofamiliar.create!(nombre: "prueba", fechacreacion: "01-01-2021")
    end

    test "should get index" do
      get :index

      assert_response :success
    end

    test "should get new" do
      get :new

      assert_response :success
    end

    test "should create miembrofamiliar" do
      assert_difference("Miembrofamiliar.count") do
        post :create, params: { miembrofamiliar: { fechacreacion: "02-01-2021", nombre: "prueba2" } }
      end

      assert_redirected_to admin_miembrofamiliar_path(assigns(:miembrofamiliar))
    end

    test "should show miembrofamiliar" do
      get :show, params: { id: @miembrofamiliar }

      assert_response :success
    end

    test "should get edit" do
      get :edit, params: { id: @miembrofamiliar }

      assert_response :success
    end

    test "should update miembrofamiliar" do
      patch :update, params: { id: @miembrofamiliar, miembrofamiliar: { created_at: @miembrofamiliar.created_at, fechacreacion: @miembrofamiliar.fechacreacion, fechadeshabilitacion: @miembrofamiliar.fechadeshabilitacion, nombre: @miembrofamiliar.nombre, observaciones: @miembrofamiliar.observaciones, updated_at: @miembrofamiliar.updated_at } }

      assert_redirected_to admin_miembrofamiliar_path(assigns(:miembrofamiliar))
    end

    test "should destroy miembrofamiliar" do
      assert_difference("Miembrofamiliar.count", -1) do
        delete :destroy, params: { id: @miembrofamiliar }
      end

      assert_redirected_to admin_miembrosfamiliar_path
    end
  end
end
