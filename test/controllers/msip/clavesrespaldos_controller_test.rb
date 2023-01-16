#require 'byebug'
require 'test_helper'
require_relative '../../models/msip/claverespaldo_test'

module Msip
  class ClavesrespaldosControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers
    include Devise::Test::IntegrationHelpers 
    include Rails.application.routes.url_helpers


    setup do
      @current_usuario = ::Usuario.create(PRUEBA_USUARIO)
      sign_in @current_usuario
      @claverespaldo = Msip::Claverespaldo.create(
        Msip::ClaverespaldoTest::PRUEBA_CLAVERESPALDO)
    end

    test "should get index" do
      get clavesrespaldos_path
      assert_response :success
    end

    test "should get new" do
      get new_claverespaldo_path
      assert_response :success
    end

    test "should create claverespaldo" do
      assert_difference 'Claverespaldo.count', 1 do
        post clavesrespaldos_path, params: {claverespaldo: {
          clave: "clave_nueva",
          created_at: "2018-10-25",
          updated_at: "2018-10-25"
        }}
      end

      assert_redirected_to claverespaldo_path(assigns(:claverespaldo))
    end

    test "should show claverespaldo" do
      get claverespaldo_path(@claverespaldo.id)
      assert_response :success
    end

  end
end
