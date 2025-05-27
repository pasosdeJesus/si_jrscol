# frozen_string_literal: true

require "test_helper"

module Admin
  class SectoresgifmmControllerTest < ActionController::TestCase
    include Devise::Test::ControllerHelpers

    setup do
      Rails.application.try(:reload_routes_unless_loaded)

      @current_usuario = ::Usuario.create(PRUEBA_USUARIO)
      sign_in @current_usuario
      @controller = Admin::SectoresgifmmController.new
      @sectorgifmm = Sectorgifmm.create!(nombre: "prueba", fechacreacion: "01-01-2021")
    end

    test "should get index" do
      get :index

      assert_response :success
    end

    test "should get new" do
      get :new

      assert_response :success
    end

    test "should create sectorgifmm" do
      assert_difference("Sectorgifmm.count") do
        post :create, params: { sectorgifmm: { fechacreacion: "02-01-2021", nombre: "prueba2" } }
      end

      assert_redirected_to admin_sectorgifmm_path(assigns(:sectorgifmm))
    end

    test "should show sectorgifmm" do
      get :show, params: { id: @sectorgifmm }

      assert_response :success
    end

    test "should get edit" do
      get :edit, params: { id: @sectorgifmm }

      assert_response :success
    end

    test "should update sectorgifmm" do
      patch :update, params: { id: @sectorgifmm, sectorgifmm: { created_at: @sectorgifmm.created_at, fechacreacion: @sectorgifmm.fechacreacion, fechadeshabilitacion: @sectorgifmm.fechadeshabilitacion, nombre: @sectorgifmm.nombre, observaciones: @sectorgifmm.observaciones, updated_at: @sectorgifmm.updated_at } }

      assert_redirected_to admin_sectorgifmm_path(assigns(:sectorgifmm))
    end

    test "should destroy sectorgifmm" do
      assert_difference("Sectorgifmm.count", -1) do
        delete :destroy, params: { id: @sectorgifmm }
      end

      assert_redirected_to admin_sectoresgifmm_path
    end
  end
end
