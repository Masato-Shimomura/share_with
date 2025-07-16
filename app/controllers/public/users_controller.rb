class Public::UsersController < ApplicationController
  def mypage
    @pending_user_groups = current_user.user_groups.pending.includes(:group)
    @user = current_user
  end
  
  def confirm_withdraw
    @user = current_user
  end
  
  def withdraw
    @user = current_user
    @user.update(is_active: false) 
    reset_session
    redirect_to root_path, notice: "退会しました"
  end
end
