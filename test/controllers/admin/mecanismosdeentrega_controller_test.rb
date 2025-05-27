# frozen_string_literal: true

require "test_helper"

module Admin
  class MecanismosdeentregaControllerTest < ActionController::TestCase
    include Devise::Test::ControllerHelpers

    setup do
      Rails.application.try(:reload_routes_unless_loaded)
      @current_usuario = ::Usuario.create(PRUEBA_USUARIO)
      sign_in @current_usuario
      @controller = Admin::MecanismosdeentregaController.new
      @mecanismodeentrega = Mecanismodeentrega.create!(nombre: "prueba", fechacreacion: "01-01-2021")
    end

    test "should get index" do
      get :index

      assert_response :success
    end

    test "should get new" do
      get :new

      assert_response :success
    end

    test "should create mecanismodeentrega" do
      assert_difference("Mecanismodeentrega.count") do
        post :create, params: { mecanismodeentrega: { fechacreacion: "01-01-2021", nombre: "prueba2" } }
      end

      assert_redirected_to admin_mecanismodeentrega_path(assigns(:mecanismodeentrega))
    end

    test "should show mecanismodeentrega" do
      get :show, params: { id: @mecanismodeentrega }

      assert_response :success
    end

    test "should get edit" do
      get :edit, params: { id: @mecanismodeentrega }

      assert_response :success
    end

    test "should update mecanismodeentrega" do
      patch :update, params: { id: @mecanismodeentrega, mecanismodeentrega: { created_at: @mecanismodeentrega.created_at, fechacreacion: @mecanismodeentrega.fechacreacion, fechadeshabilitacion: @mecanismodeentrega.fechadeshabilitacion, nombre: @mecanismodeentrega.nombre, observaciones: @mecanismodeentrega.observaciones, updated_at: @mecanismodeentrega.updated_at } }

      assert_redirected_to admin_mecanismodeentrega_path(assigns(:mecanismodeentrega))
    end

    test "should destroy mecanismodeentrega" do
      assert_difference("Mecanismodeentrega.count", -1) do
        delete :destroy, params: { id: @mecanismodeentrega }
      end

      assert_redirected_to admin_mecanismosdeentrega_path
    end
  end
end
