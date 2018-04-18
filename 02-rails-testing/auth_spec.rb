require 'rails_helper'

RSpec.describe "Auth", type: :request do
  before do
    @user = User.create!(email: "xxx@example.com", name:"", password: "12345678")
  end

  describe "POST /api/v1/login" do
    it "should be error if email or password is wrong" do
      post "/api/v1/login"

      data = {
        "message" => "email or password is not correct"
      }
      expect(response).to have_http_status(401)
      expect( JSON.parse(response.body) ).to eq(data)
    end

    it "should return token if email and password are correct" do
      post "/api/v1/login", params: { email: @user.email, password: "12345678" }

      data = {
        "user_id" => @user.id,
        "auth_token" => @user.authentication_token
      }
      expect(response).to have_http_status(200)
      expect( JSON.parse(response.body) ).to eq(data)
    end

  end

  describe "POST /api/v1/logout" do

    it "logout without login should get error" do
      post "/api/v1/logout"
      expect(response).to have_http_status(401)
    end

    it "should reset authentication_token" do
      old_auth_token = @user.authentication_token
      post "/api/v1/logout", params: { auth_token: @user.authentication_token }

      expect(response).to have_http_status(200)

      @user.reload

      expect(@user.authentication_token).to_not eq( old_auth_token )
    end

    it "should return 401 if token is wrong" do
      post "/api/v1/logout", params: { auth_token: "ooxx"}

      expect(response).to have_http_status(401)
    end
  end


end
