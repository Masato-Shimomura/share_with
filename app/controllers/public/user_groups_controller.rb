class Public::UserGroupsController < ApplicationController
  before_action :authenticate_user!

  def accept
    user_group = current_user.user_groups.find(params[:id])
    if user_group.pending?
      user_group.update(status: :accepted)
      flash[:notice] = "グループ参加を承認しました。"
    else
      flash[:alert] = "不正な操作です。"
    end
    redirect_to users_mypage_path
  end

  def reject
    user_group = current_user.user_groups.find(params[:id])
    if user_group.pending?
      user_group.destroy
      flash[:alert] = "招待を辞退しました。"
    else
      flash[:alert] = "不正な操作です。"
    end
    redirect_to users_mypage_path
  end
end
