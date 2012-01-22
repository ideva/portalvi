require 'test_helper'

class InstalasiLayanansControllerTest < ActionController::TestCase
  setup do
    @instalasi_layanan = instalasi_layanans(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:instalasi_layanans)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create instalasi_layanan" do
    assert_difference('InstalasiLayanan.count') do
      post :create, :instalasi_layanan => @instalasi_layanan.attributes
    end

    assert_redirected_to instalasi_layanan_path(assigns(:instalasi_layanan))
  end

  test "should show instalasi_layanan" do
    get :show, :id => @instalasi_layanan.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @instalasi_layanan.to_param
    assert_response :success
  end

  test "should update instalasi_layanan" do
    put :update, :id => @instalasi_layanan.to_param, :instalasi_layanan => @instalasi_layanan.attributes
    assert_redirected_to instalasi_layanan_path(assigns(:instalasi_layanan))
  end

  test "should destroy instalasi_layanan" do
    assert_difference('InstalasiLayanan.count', -1) do
      delete :destroy, :id => @instalasi_layanan.to_param
    end

    assert_redirected_to instalasi_layanans_path
  end
end
