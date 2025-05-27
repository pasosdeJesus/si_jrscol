# frozen_string_literal: true

require "test_helper"
require_relative "../../models/territorial_test"

module Admin
  class TerritorialesControllerTest < ActionController::TestCase
    include Devise::Test::ControllerHelpers
    include Rails.application.routes.url_helpers

    setup do
      Rails.application.try(:reload_routes_unless_loaded)
      @current_usuario = ::Usuario.create(PRUEBA_USUARIO)
      sign_in @current_usuario
      @territorial = ::Territorial.create(
        ::TerritorialTest::PRUEBA_TERRITORIAL,
      )
      @controller = ::Admin::TerritorialesController.new
    end

    test "debe presentar listado" do
      get :index # , params: {use_route: admin_territoriales_path}

      assert_response :success
    end

    test "debe presentar formulario de nuevo" do
      get :new # , params: {use_route: admin_territoriales_path}

      assert_response :success
    end

    test "debe crear" do
      assert_difference("Territorial.count") do
        post :create, params: { territorial: { nombre: "prueba2", fechacreacion: "01-01-2021" } }
      end
    end

    test "debe presentar resumen" do
      get :show, params: { id: @territorial }

      assert_response :success
    end

    test "debe presentar formulario de edición" do
      get :edit, params: { id: @territorial }

      assert_response :success
    end

    test "debe actualizar" do
      patch :update, params: { id: @territorial, territorial: { created_at: @territorial.created_at, fechacreacion: @territorial.fechacreacion, fechadeshabilitacion: @territorial.fechadeshabilitacion, nombre: @territorial.nombre, observaciones: @territorial.observaciones, updated_at: @territorial.updated_at } }
    end

    test "debe destruir" do
      assert_difference("Territorial.count", -1) do
        delete :destroy, params: { id: @territorial }
      end
    end
  end
end
