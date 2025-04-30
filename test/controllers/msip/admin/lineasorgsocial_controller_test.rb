require 'test_helper'
require_relative '../../../models/msip/lineaorgsocial_test'

module Msip
  module Admin

    class LineasorgsocialControllerTest < ActionController::TestCase
      include Engine.routes.url_helpers
      include Devise::Test::ControllerHelpers
      include Rails.application.routes.url_helpers


      setup do
        Rails.application.try(:reload_routes_unless_loaded)
        @current_usuario = ::Usuario.create(PRUEBA_USUARIO)
        sign_in @current_usuario
        @lineaorgsocial = Msip::Lineaorgsocial.create(
          Msip::LineaorgsocialTest::PRUEBA_LINEAORGSOCIAL)
        @controller = Msip::Admin::LineasorgsocialController.new 
      end

      test "should get index" do
        get :index, params: {use_route: admin_lineasorgsocial_path}
        assert_response :success
      end

      test "should get new" do
        get :new, params: {use_route: admin_lineasorgsocial_path}
        assert_response :success
      end

      test "should create lineaorgsocial" do
        assert_difference('Lineaorgsocial.count') do
          post :create, params: {use_route: admin_lineasorgsocial_path, lineaorgsocial: { nombre: 'prueba2', fechacreacion: '01-01-2021' }}
        end
      end

      test "should show lineaorgsocial" do
        get :show, params: {use_route: admin_lineaorgsocial_path, id: @lineaorgsocial}
        assert_response :success
      end

      test "should get edit" do
        get :edit, params: {use_route: admin_lineaorgsocial_path, id: @lineaorgsocial}
        assert_response :success
      end

      test "should update lineaorgsocial" do
        patch :update, params: {use_route: admin_lineaorgsocial_path, id: @lineaorgsocial, lineaorgsocial: { created_at: @lineaorgsocial.created_at, fechacreacion: @lineaorgsocial.fechacreacion, fechadeshabilitacion: @lineaorgsocial.fechadeshabilitacion, nombre: @lineaorgsocial.nombre, observaciones: @lineaorgsocial.observaciones, updated_at: @lineaorgsocial.updated_at }}
      end

      test "should destroy lineaorgsocial" do
        assert_difference('Lineaorgsocial.count', -1) do
          delete :destroy, params: {use_route: admin_lineaorgsocial_path, id: @lineaorgsocial}
        end
      end
    end

  end
end
