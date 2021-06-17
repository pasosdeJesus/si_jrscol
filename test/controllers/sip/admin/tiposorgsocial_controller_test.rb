#require 'byebug'
require 'test_helper'
require_relative '../../../models/sip/tipoorgsocial_test'

module Sip
  module Admin

    class TiposorgsocialControllerTest < ActionController::TestCase
      include Engine.routes.url_helpers
      include Devise::Test::IntegrationHelpers 
      include Rails.application.routes.url_helpers


      setup do
        @tipoorgsocial = Sip::Tipoorgsocial.create(
          Sip::TipoorgsocialTest::PRUEBA_TIPOORGSOCIAL)
        #byebug
        #@controller = Sip::Admin::TiposorgsocialController
      end

      test "should get index" do
        skip
        get tiposorgsocial_url
        assert_response :success
        assert_not_nil assigns(:tipoorgsocial)
      end

      test "should get new" do
        skip
        get :new
        assert_response :success
      end

      test "should create tipoorgsocial" do
        skip
        assert_difference('Tipoorgsocial.count') do
          post :create, tipoorgsocial: { created_at: @tipoorgsocial.created_at, fechacreacion: @tipoorgsocial.fechacreacion, fechadeshabilitacion: @tipoorgsocial.fechadeshabilitacion, nombre: @tipoorgsocial.nombre, observaciones: @tipoorgsocial.observaciones, updated_at: @tipoorgsocial.updated_at }
        end

        assert_redirected_to tipoorgsocial_path(assigns(:tipoorgsocial))
      end

      test "should show tipoorgsocial" do
        skip
        get :show, id: @tipoorgsocial
        assert_response :success
      end

      test "should get edit" do
        skip
        get :edit, id: @tipoorgsocial
        assert_response :success
      end

      test "should update tipoorgsocial" do
        skip
        patch :update, id: @tipoorgsocial, tipoorgsocial: { created_at: @tipoorgsocial.created_at, fechacreacion: @tipoorgsocial.fechacreacion, fechadeshabilitacion: @tipoorgsocial.fechadeshabilitacion, nombre: @tipoorgsocial.nombre, observaciones: @tipoorgsocial.observaciones, updated_at: @tipoorgsocial.updated_at }
        assert_redirected_to tipoorgsocial_path(assigns(:tipoorgsocial))
      end

      test "should destroy tipoorgsocial" do
        skip
        assert_difference('Tipoorgsocial.count', -1) do
          delete :destroy, id: @tipoorgsocial
        end

        assert_redirected_to tiposorgsocial_path
      end
    end

  end
end
