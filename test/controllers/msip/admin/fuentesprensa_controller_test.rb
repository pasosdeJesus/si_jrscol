# frozen_string_literal: true

require "test_helper"
require_relative "../../../models/msip/fuenteprensa_test"

module Msip
  module Admin
    class FuentesprensaControllerTest < ActionController::TestCase
      include Engine.routes.url_helpers
      include Devise::Test::ControllerHelpers
      include Rails.application.routes.url_helpers

      setup do
        @current_usuario = ::Usuario.create(PRUEBA_USUARIO)
        sign_in @current_usuario
        @fuenteprensa = Msip::Fuenteprensa.create(
          Msip::FuenteprensaTest::PRUEBA_FUENTEPRENSA,
        )
        @controller = Msip::Admin::FuentesprensaController.new
      end

      test "should get index" do
        get :index, params: { use_route: admin_fuentesprensa_path }

        assert_response :success
      end

      test "should get new" do
        get :new, params: { use_route: admin_fuentesprensa_path }

        assert_response :success
      end

      test "should create fuenteprensa" do
        assert_difference("Fuenteprensa.count") do
          post :create, params: { use_route: admin_fuentesprensa_path, fuenteprensa: { nombre: "prueba2", fechacreacion: "01-01-2021" } }
        end
      end

      test "should show fuenteprensa" do
        get :show, params: { use_route: admin_fuenteprensa_path, id: @fuenteprensa }

        assert_response :success
      end

      test "should get edit" do
        get :edit, params: { use_route: admin_fuenteprensa_path, id: @fuenteprensa }

        assert_response :success
      end

      test "should update fuenteprensa" do
        patch :update, params: { use_route: admin_fuenteprensa_path, id: @fuenteprensa, fuenteprensa: { created_at: @fuenteprensa.created_at, fechacreacion: @fuenteprensa.fechacreacion, fechadeshabilitacion: @fuenteprensa.fechadeshabilitacion, nombre: @fuenteprensa.nombre, observaciones: @fuenteprensa.observaciones, updated_at: @fuenteprensa.updated_at } }
      end

      test "should destroy fuenteprensa" do
        assert_difference("Fuenteprensa.count", -1) do
          delete :destroy, params: { use_route: admin_fuenteprensa_path, id: @fuenteprensa }
        end
      end
    end
  end
end
