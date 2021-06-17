require 'test_helper'
require_relative '../../../models/sip/lineaorgsocial_test'

module Sip
  module Admin

    class LineasorgsocialControllerTest < ActionController::TestCase
      include Engine.routes.url_helpers
      include Devise::Test::IntegrationHelpers 
      include Rails.application.routes.url_helpers


      setup do
        @lineaorgsocial = Sip::Lineaorgsocial.create(
          Sip::LineaorgsocialTest::PRUEBA_LINEAORGSOCIAL)
        #byebug
        #@controller = Sip::Admin::LineasorgsocialController
      end

      test "should get index" do
        skip
        get lineasorgsocial_url
        assert_response :success
        assert_not_nil assigns(:lineaorgsocial)
      end

      test "should get new" do
        skip
        get :new
        assert_response :success
      end

      test "should create lineaorgsocial" do
        skip
        assert_difference('Lineaorgsocial.count') do
          post :create, lineaorgsocial: { created_at: @lineaorgsocial.created_at, fechacreacion: @lineaorgsocial.fechacreacion, fechadeshabilitacion: @lineaorgsocial.fechadeshabilitacion, nombre: @lineaorgsocial.nombre, observaciones: @lineaorgsocial.observaciones, updated_at: @lineaorgsocial.updated_at }
        end

        assert_redirected_to lineaorgsocial_path(assigns(:lineaorgsocial))
      end

      test "should show lineaorgsocial" do
        skip
        get :show, id: @lineaorgsocial
        assert_response :success
      end

      test "should get edit" do
        skip
        get :edit, id: @lineaorgsocial
        assert_response :success
      end

      test "should update lineaorgsocial" do
        skip
        patch :update, id: @lineaorgsocial, lineaorgsocial: { created_at: @lineaorgsocial.created_at, fechacreacion: @lineaorgsocial.fechacreacion, fechadeshabilitacion: @lineaorgsocial.fechadeshabilitacion, nombre: @lineaorgsocial.nombre, observaciones: @lineaorgsocial.observaciones, updated_at: @lineaorgsocial.updated_at }
        assert_redirected_to lineaorgsocial_path(assigns(:lineaorgsocial))
      end

      test "should destroy lineaorgsocial" do
        skip
        assert_difference('Lineaorgsocial.count', -1) do
          delete :destroy, id: @lineaorgsocial
        end

        assert_redirected_to lineasorgsocial_path
      end
    end

  end
end
