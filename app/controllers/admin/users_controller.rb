class Admin::UsersController < Admin::ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def index
    @keyword = params[:keyword]
  
    @users = User
               .includes(:groups, :posts)
               .order(created_at: :desc)
  
    if @keyword.present?
      @users = @users.where(
        "last_name LIKE ? OR first_name LIKE ? OR email LIKE ?",
        "%#{@keyword}%",
        "%#{@keyword}%",
        "%#{@keyword}%"
      )
    end
  end  

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to admin_user_path(@user), notice: "ユーザー情報を更新しました。"
    else
      render :edit
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.update(is_active: false)
    redirect_to admin_users_path, notice: "ユーザーを退会状態にしました。"
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:last_name, :first_name, :email, :is_active)
  end  

end
