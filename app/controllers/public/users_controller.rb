class Public::UsersController < ApplicationController
  def mypage
    @pending_user_groups = current_user.user_groups.pending.includes(:group)
    @user = current_user
  end

  def show
    @user = User.find(params[:id])
    unless @user.is_active
      redirect_to public_users_path, alert: "このユーザーは退会済みです" and return
    end
  end

  def index
    @keyword = params[:keyword]
    @users = User.where(is_active: true).where.not(id: current_user.id)
  
    if @keyword.present?
      keyword = "%#{@keyword}%"
      @users = @users.where("last_name LIKE ? OR first_name LIKE ? OR email LIKE ?", keyword, keyword, keyword)
    end
  end
  
  def confirm_withdraw
    @user = current_user
  end
  
  def withdraw
    @user = current_user
  
    ActiveRecord::Base.transaction do
      # 退会ユーザーが作成者のグループのowner_idをnullに
      Group.where(owner_id: @user.id).update_all(owner_id: nil)
      # ユーザーの論理削除
      @user.update!(is_active: false)
    end
  
    reset_session
    redirect_to root_path, notice: "退会しました"
  rescue ActiveRecord::RecordInvalid
    flash[:alert] = "退会処理に失敗しました"
    redirect_to mypage_public_users_path
  end
end
