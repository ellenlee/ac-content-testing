class ApiV1::AuthController < ApiController

  before_action :authenticate_user!, :only => [:logout]

  # POST /api/v1/login
  def login
    success = false

    if params[:email] && params[:password]
      user = User.find_by_email( params[:email] )
      success = user && user.valid_password?( params[:password] )
    end

    if success
      render json: { auth_token: user.authentication_token,
                     user_id: user.id}
    else
      render json: { message: "email or password is not correct" }, status: 401
    end

  end

  # POST /api/v1/logout
  def logout
    user = current_user
    user.generate_authentication_token
    user.save!

    render json: { message: "ok" }
  end

end
