class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update, :destroy]

  def me
    render json: current_user
  end

  def index
    users = User.all
    authorize users
    render json: users
  end

  def show
    authorize @user
    render json: @user
  end

  def update
    authorize @user
    if @user.update(user_params)
      render json: @user
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @user
    @user.destroy
    head :no_content
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :role)
  end
end