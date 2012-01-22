require 'test_helper'

class DoktersControllerTest < ActionController::TestCase
  setup do
    @dokter = dokters(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:dokters)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create dokter" do
    assert_difference('Dokter.count') do
      post :create, :dokter => @dokter.attributes
    end

    assert_redirected_to dokter_path(assigns(:dokter))
  end

  test "should show dokter" do
    get :show, :id => @dokter.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @dokter.to_param
    assert_response :success
  end

  test "should update dokter" do
    put :update, :id => @dokter.to_param, :dokter => @dokter.attributes
    assert_redirected_to dokter_path(assigns(:dokter))
  end

  test "should destroy dokter" do
    assert_difference('Dokter.count', -1) do
      delete :destroy, :id => @dokter.to_param
    end

    assert_redirected_to dokters_path
  end
end
