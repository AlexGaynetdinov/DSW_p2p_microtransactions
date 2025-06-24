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
    return render json: { error: 'Forbidden' }, status: :forbidden unless current_user.admin?

    user = User.find_by(id: params[:id])
    if user.nil?
      return render json: { error: 'User not found' }, status: :not_found
    end

    user.soft_delete
    render json: { message: 'User marked as deleted' }
  end

  def merchants
    merchants = User.where(role: 'merchant').select(:id, :name, :email)
    render json: merchants
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :role)
  end
end