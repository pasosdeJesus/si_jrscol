# frozen_string_literal: true

require "test_helper"

module Admin
  class MigracontactospreControllerTest < ActionController::TestCase
    include Devise::Test::ControllerHelpers

    setup do
      @current_usuario = ::Usuario.create(PRUEBA_USUARIO)
      sign_in @current_usuario
      @controller = Admin::MigracontactospreController.new
      @migracontactopre = Migracontactopre.create!(nombre: "prueba", fechacreacion: "01-01-2021")
    end

    test "should get index" do
      get :index

      assert_response :success
    end

    test "should get new" do
      get :new

      assert_response :success
    end

    test "should create migracontactopre" do
      assert_difference("Migracontactopre.count") do
        post :create, params: { migracontactopre: { fechacreacion: "01-01-2021", nombre: "prueba2" } }
      end

      assert_redirected_to admin_migracontactopre_path(assigns(:migracontactopre))
    end

    test "should show migracontactopre" do
      get :show, params: { id: @migracontactopre }

      assert_response :success
    end

    test "should get edit" do
      get :edit, params: { id: @migracontactopre }

      assert_response :success
    end

    test "should update migracontactopre" do
      patch :update, params: { id: @migracontactopre, migracontactopre: { created_at: @migracontactopre.created_at, fechacreacion: @migracontactopre.fechacreacion, fechadeshabilitacion: @migracontactopre.fechadeshabilitacion, nombre: @migracontactopre.nombre, observaciones: @migracontactopre.observaciones, updated_at: @migracontactopre.updated_at } }

      assert_redirected_to admin_migracontactopre_path(assigns(:migracontactopre))
    end

    test "should destroy migracontactopre" do
      assert_difference("Migracontactopre.count", -1) do
        delete :destroy, params: { id: @migracontactopre }
      end

      assert_redirected_to admin_migracontactospre_path
    end
  end
end
