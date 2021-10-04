require 'test_helper'

module Admin
  class ModalidadesentregaControllerTest < ActionController::TestCase
    include Devise::Test::ControllerHelpers

    setup do
      @current_usuario = ::Usuario.create(PRUEBA_USUARIO)
      sign_in @current_usuario
      @controller = Admin::ModalidadesentregaController.new
      @modalidadentrega = Modalidadentrega.create!(nombre: 'prueba', fechacreacion: '01-01-2021')
    end

    test "should get index" do
      get :index
      assert_response :success
    end

    test "should get new" do
      get :new
      assert_response :success
    end

    test "should create modalidadentrega" do
      assert_difference('Modalidadentrega.count') do
        post :create, params: { modalidadentrega: { fechacreacion: '01-01-2021', nombre: 'prueba2' }}
      end

      assert_redirected_to admin_modalidadentrega_path(assigns(:modalidadentrega))

    end

    test "should show modalidadentrega" do
      get :show, params: { id: @modalidadentrega}
      assert_response :success
    end

    test "should get edit" do
      get :edit, params:{ id: @modalidadentrega}
      assert_response :success
    end

    test "should update modalidadentrega" do
      patch :update, params:{ id: @modalidadentrega, modalidadentrega: { created_at: @modalidadentrega.created_at, fechacreacion: @modalidadentrega.fechacreacion, fechadeshabilitacion: @modalidadentrega.fechadeshabilitacion, nombre: @modalidadentrega.nombre, observaciones: @modalidadentrega.observaciones, updated_at: @modalidadentrega.updated_at }}
      assert_redirected_to admin_modalidadentrega_path(assigns(:modalidadentrega))
    end

    test "should destroy modalidadentrega" do
      assert_difference('Modalidadentrega.count', -1) do
        delete :destroy, params:{ id: @modalidadentrega} 
      end

      assert_redirected_to admin_modalidadesentrega_path
    end
  end
end
