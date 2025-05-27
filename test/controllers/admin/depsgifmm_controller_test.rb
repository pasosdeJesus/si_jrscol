# frozen_string_literal: true

require "test_helper"

module Admin
  class DepsgifmmControllerTest < ActionController::TestCase
    include Devise::Test::ControllerHelpers

    setup do
      Rails.application.try(:reload_routes_unless_loaded)
      @current_usuario = ::Usuario.create(PRUEBA_USUARIO)
      sign_in @current_usuario
      @controller = Admin::DepsgifmmController.new
      @depgifmm = Depgifmm.create!(nombre: "prueba", fechacreacion: "01-01-2021")
    end

    test "should get index" do
      get :index

      assert_response :success
    end

    test "should get new" do
      get :new

      assert_response :success
    end

    test "should create depgifmm" do
      assert_difference("Depgifmm.count") do
        post :create, params: { depgifmm: { fechacreacion: "02-01-2021", nombre: "prueba2" } }
      end

      assert_redirected_to admin_depgifmm_path(assigns(:depgifmm))
    end

    test "should show depgifmm" do
      get :show, params: { id: @depgifmm }

      assert_response :success
    end

    test "should get edit" do
      get :edit, params: { id: @depgifmm }

      assert_response :success
    end

    test "should update depgifmm" do
      patch :update, params: { id: @depgifmm, depgifmm: { created_at: @depgifmm.created_at, fechacreacion: @depgifmm.fechacreacion, fechadeshabilitacion: @depgifmm.fechadeshabilitacion, nombre: @depgifmm.nombre, observaciones: @depgifmm.observaciones, updated_at: @depgifmm.updated_at } }

      assert_redirected_to admin_depgifmm_path(assigns(:depgifmm))
    end

    test "should destroy depgifmm" do
      assert_difference("Depgifmm.count", -1) do
        delete :destroy, params: { id: @depgifmm }
      end

      assert_redirected_to admin_depsgifmm_path
    end
  end
end
