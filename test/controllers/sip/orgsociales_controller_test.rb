#require 'byebug'
require 'test_helper'
require_relative '../../models/sip/orgsocial_test'

module Sip
  class OrgsocialesControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers
    include Devise::Test::IntegrationHelpers 
    include Rails.application.routes.url_helpers


    setup do
      @current_usuario = ::Usuario.create(PRUEBA_USUARIO)
      sign_in @current_usuario
      @grupoper = Sip::Grupoper.create!(PRUEBA_GRUPOPER)
    end

    test "should get index" do
      get orgsociales_path
      assert_response :success
    end

    test "should get new" do
      get new_orgsocial_path
      assert_response :success
    end

    test "should create orgsocial" do
      skip
      assert_difference 'Orgsocial.count', 1 do
        post orgsociales_path, params: {orgsocial: PRUEBA_ORGSOCIAL}
      end
      assert_redirected_to orgsociales_path
    end

    test "should show orgsocial" do
      @orgsocial = Sip::Orgsocial.create!(PRUEBA_ORGSOCIAL)
      get orgsocial_path(@orgsocial.id)
      assert_response :success
    end

  end
end
