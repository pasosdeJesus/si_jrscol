# frozen_string_literal: true

require "test_helper"
require_relative "../../../models/msip/tipoanexo_test"

module Msip
  module Admin
    class TiposanexoControllerTest < ActionController::TestCase
      include Engine.routes.url_helpers
      include Devise::Test::ControllerHelpers
      include Rails.application.routes.url_helpers

      setup do
        Rails.application.try(:reload_routes_unless_loaded)
        @current_usuario = ::Usuario.create(PRUEBA_USUARIO)
        sign_in @current_usuario
        @tipoanexo = Msip::Tipoanexo.create(
          Msip::TipoanexoTest::PRUEBA_TIPOANEXO,
        )
        @controller = Msip::Admin::TiposanexoController.new
      end

      test "should get index" do
        get :index, params: { use_route: admin_tiposanexo_path }

        assert_response :success
      end

      test "should get new" do
        get :new, params: { use_route: admin_tiposanexo_path }

        assert_response :success
      end

      test "should create tipoanexo" do
        assert_difference("Tipoanexo.count") do
          post :create, params: { use_route: admin_tiposanexo_path, tipoanexo: { nombre: "prueba2", fechacreacion: "01-01-2021" } }
        end
      end

      test "should show tipoanexo" do
        get :show, params: { use_route: admin_tipoanexo_path, id: @tipoanexo }

        assert_response :success
      end

      test "should get edit" do
        get :edit, params: { use_route: admin_tipoanexo_path, id: @tipoanexo }

        assert_response :success
      end

      test "should update tipoanexo" do
        patch :update, params: { use_route: admin_tipoanexo_path, id: @tipoanexo, tipoanexo: { created_at: @tipoanexo.created_at, fechacreacion: @tipoanexo.fechacreacion, fechadeshabilitacion: @tipoanexo.fechadeshabilitacion, nombre: @tipoanexo.nombre, observaciones: @tipoanexo.observaciones, updated_at: @tipoanexo.updated_at } }
      end

      test "should destroy tipoanexo" do
        assert_difference("Tipoanexo.count", -1) do
          delete :destroy, params: { use_route: admin_tipoanexo_path, id: @tipoanexo }
        end
      end
    end
  end
end
