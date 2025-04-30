#require 'byebug'
require 'test_helper'
require_relative '../../../models/msip/tipoorgsocial_test'

module Msip
  module Admin

    class TiposorgsocialControllerTest < ActionDispatch::IntegrationTest
      include Engine.routes.url_helpers
      include Devise::Test::IntegrationHelpers 
      include Rails.application.routes.url_helpers


      setup do
        Rails.application.try(:reload_routes_unless_loaded)
        @current_usuario = ::Usuario.create(PRUEBA_USUARIO)
        sign_in @current_usuario
        @tipoorgsocial = Msip::Tipoorgsocial.create(
          PRUEBA_TIPOORGSOCIAL)
      end

      test "should get index" do
        get admin_tiposorgsocial_path
        assert_response :success
      end

      test "should get new" do
        get new_admin_tipoorgsocial_path
        assert_response :success
      end

      test "should create tipoorgsocial" do
        assert_difference 'Tipoorgsocial.count', 1 do
          post admin_tiposorgsocial_path, params: {tipoorgsocial: {
            nombre: "Tipoorgsocial_pruebale",
            observaciones: "obs",
            fechacreacion: "2018-10-25",
            created_at: "2018-10-25",
            updated_at: "2018-10-25"
          }}
        end

        assert_redirected_to admin_tipoorgsocial_path(assigns(:tipoorgsocial))
      end

      test "should show tipoorgsocial" do
        get admin_tipoorgsocial_path(@tipoorgsocial.id)
        assert_response :success
      end

      test "should get edit" do
        get edit_admin_tipoorgsocial_path(@tipoorgsocial.id)
        assert_response :success
      end

      test "should update tipoorgsocial" do
        patch admin_tipoorgsocial_path(@tipoorgsocial.id, params: { tipoorgsocial: { 
            nombre: "Tipoorgsocial_pruebacambio",
            observaciones: "obs",
            fechacreacion: "2018-10-25",
            created_at: "2018-10-25",
            updated_at: "2018-10-25"
        }})
      end

      test "should destroy tipoorgsocial" do
        assert_difference('Msip::Tipoorgsocial.count', -1) do
          delete admin_tipoorgsocial_path(@tipoorgsocial.id)
        end

        assert_redirected_to admin_tiposorgsocial_path
      end
    end

  end
end
