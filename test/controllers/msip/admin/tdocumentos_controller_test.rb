# frozen_string_literal: true

# require 'byebug'
require "test_helper"
require_relative "../../../models/msip/tdocumento_test"

module Msip
  module Admin
    class TdocumentosControllerTest < ActionDispatch::IntegrationTest
      include Engine.routes.url_helpers
      include Devise::Test::IntegrationHelpers
      include Rails.application.routes.url_helpers

      setup do
        Rails.application.try(:reload_routes_unless_loaded)
        @current_usuario = ::Usuario.create(PRUEBA_USUARIO)
        sign_in @current_usuario
        @tdocumento = Msip::Tdocumento.create(
          Msip::TdocumentoTest::PRUEBA_TDOCUMENTO,
        )
      end

      test "should get index" do
        get admin_tdocumentos_path

        assert_response :success
      end

      test "should get new" do
        get new_admin_tdocumento_path

        assert_response :success
      end

      test "should create tdocumento" do
        assert_difference "Tdocumento.count", 1 do
          post admin_tdocumentos_path, params: {
            tdocumento: {
              nombre: "Tdocumento_pruebale",
              sigla: "td",
              ayuda: "ayuda",
              formatoregex: "regex",
              observaciones: "obs",
              fechacreacion: "2018-10-25",
              created_at: "2018-10-25",
              updated_at: "2018-10-25",
            },
          }
        end

        assert_redirected_to admin_tdocumento_path(assigns(:tdocumento))
      end

      test "should show tdocumento" do
        get admin_tdocumento_path(@tdocumento.id)

        assert_response :success
      end

      test "should get edit" do
        get edit_admin_tdocumento_path(@tdocumento.id)

        assert_response :success
      end

      test "should update tdocumento" do
        patch admin_tdocumento_path(@tdocumento.id, params: {
          tdocumento: {
            nombre: "Tdocumento_pruebacambio",
            sigla: "td",
            ayuda: "ayuda",
            formatoregex: "regex",
            observaciones: "obs",
            fechacreacion: "2018-10-25",
            created_at: "2018-10-25",
            updated_at: "2018-10-25",
          },
        })
      end

      test "should destroy tdocumento" do
        assert_difference("Msip::Tdocumento.count", -1) do
          delete admin_tdocumento_path(@tdocumento.id)
        end

        assert_redirected_to admin_tdocumentos_path
      end
    end
  end
end
