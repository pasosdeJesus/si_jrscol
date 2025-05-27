# frozen_string_literal: true

require "test_helper"

module Admin
  class EspaciospartControllerTest < ActionController::TestCase
    include Devise::Test::ControllerHelpers

    setup do
      @current_usuario = ::Usuario.create(PRUEBA_USUARIO)
      sign_in @current_usuario
      @controller = Admin::EspaciospartController.new
      @espaciopart = Espaciopart.create!(nombre: "prueba", fechacreacion: "01-01-2021")
    end

    test "should get index" do
      get :index

      assert_response :success
    end

    test "should get new" do
      get :new

      assert_response :success
    end

    test "should create espaciopart" do
      assert_difference("Espaciopart.count") do
        post :create, params: { espaciopart: { fechacreacion: "02-01-2021", nombre: "prueba2" } }
      end

      assert_redirected_to admin_espaciopart_path(assigns(:espaciopart))
    end

    test "should show espaciopart" do
      get :show, params: { id: @espaciopart }

      assert_response :success
    end

    test "should get edit" do
      get :edit, params: { id: @espaciopart }

      assert_response :success
    end

    test "should update espaciopart" do
      patch :update, params: { id: @espaciopart, espaciopart: { created_at: @espaciopart.created_at, fechacreacion: @espaciopart.fechacreacion, fechadeshabilitacion: @espaciopart.fechadeshabilitacion, nombre: @espaciopart.nombre, observaciones: @espaciopart.observaciones, updated_at: @espaciopart.updated_at } }

      assert_redirected_to admin_espaciopart_path(assigns(:espaciopart))
    end

    test "should destroy espaciopart" do
      assert_difference("Espaciopart.count", -1) do
        delete :destroy, params: { id: @espaciopart }
      end

      assert_redirected_to admin_espaciospart_path
    end
  end
end
