# frozen_string_literal: true

require "test_helper"
require_relative "../../../models/msip/oficina_test"

module Msip
  module Admin
    class OficinasControllerTest < ActionController::TestCase
      include Engine.routes.url_helpers
      include Devise::Test::ControllerHelpers
      include Rails.application.routes.url_helpers

      setup do
        @current_usuario = ::Usuario.create(PRUEBA_USUARIO)
        sign_in @current_usuario
        @oficina = Msip::Oficina.create(
          Msip::OficinaTest::PRUEBA_OFICINA,
        )
        @controller = Msip::Admin::OficinasController.new
      end

      test "should get index" do
        get :index, params: { use_route: admin_oficinas_path }

        assert_response :success
      end

      test "should get new" do
        get :new, params: { use_route: admin_oficinas_path }

        assert_response :success
      end

      test "should create oficina" do
        assert_difference("Oficina.count") do
          post :create, params: {
            use_route: admin_oficinas_path,
            oficina: {
              nombre: "prueba2",
              territorial_id: 1,
              fechacreacion: "01-01-2021",
            },
          }
        end
      end

      test "should show oficina" do
        get :show, params: { use_route: admin_oficina_path, id: @oficina }

        assert_response :success
      end

      test "should get edit" do
        get :edit, params: { use_route: admin_oficina_path, id: @oficina }

        assert_response :success
      end

      test "should update oficina" do
        patch :update, params: { use_route: admin_oficina_path, id: @oficina, oficina: { created_at: @oficina.created_at, fechacreacion: @oficina.fechacreacion, fechadeshabilitacion: @oficina.fechadeshabilitacion, nombre: @oficina.nombre, observaciones: @oficina.observaciones, updated_at: @oficina.updated_at } }
      end

      test "should destroy oficina" do
        assert_difference("Oficina.count", -1) do
          delete :destroy, params: { use_route: admin_oficina_path, id: @oficina }
        end
      end
    end
  end
end
