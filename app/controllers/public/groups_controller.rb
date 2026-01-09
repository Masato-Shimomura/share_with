class Public::GroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group, only: [:show, :edit, :update, :destroy, :calendar, :confirm_withdraw, :withdraw]
  before_action :authorize_group_owner!, only: [:edit, :update, :destroy]


  def accept_invitation
    user_group = current_user.user_groups.find_by(group_id: params[:id], status: :pending)
    if user_group
      user_group.update(status: :accepted)
      flash[:notice] = "グループに参加しました"
    else
      flash[:alert] = "有効な招待が見つかりませんでした"
    end
    redirect_to mypage_public_users_path  
  end
  
  def reject_invitation
    user_group = current_user.user_groups.find_by(group_id: params[:id], status: :pending)
    if user_group
      user_group.destroy
      flash[:notice] = "招待を辞退しました"
    else
      flash[:alert] = "辞退する招待が見つかりませんでした"
    end
    redirect_to mypage_public_users_path  
  end

  def index
    @groups = current_user.groups
  end

  def new
    @group = Group.new

    
   if params[:invited_user_ids].present?
    
    @invited_user_ids = params[:invited_user_ids].map(&:to_i)
   else
    @invited_user_ids = []
   end
  end

  def create
    @group = Group.new(group_params)
    @group.owner_id = current_user.id

    if @group.save
      current_user.user_groups.create(group: @group, status: :accepted)

      if params[:invited_user_ids].present?
        params[:invited_user_ids].each do |user_id|
          UserGroup.create(user_id: user_id, group_id: @group.id, status: :pending)
        end
      end

      redirect_to public_groups_path, notice: "グループを作成し、招待を送信しました"
    else

      @invited_user_ids = params[:invited_user_ids]&.map(&:to_i) || []
      render :new
    end
  end

  def show
    @group = Group.find(params[:id])
    @members = @group.user_groups.where(status: :accepted).includes(:user).map(&:user)
    @post = Post.new
    @posts = @group.posts.order(created_at: :desc)
  end

  def invite

    if params[:keyword].present?
      keyword = params[:keyword]
      @users = User.active.where("last_name LIKE ? OR first_name LIKE ? OR email LIKE ?", 
                          "%#{keyword}%", "%#{keyword}%", "%#{keyword}%")
                   .where.not(id: current_user.id)
    else
      @users = User.active.where.not(id: current_user.id)
    end
  end
  
  
  def send_invites
    @group = Group.find(params[:id])
    
    if params[:invited_user_ids].present?
      params[:invited_user_ids].each do |user_id|
        
        unless @group.user_groups.exists?(user_id: user_id)
          @group.user_groups.create(user_id: user_id, status: :pending)
        end
      end
      flash[:notice] = "メンバーを招待しました"
    else
      flash[:alert] = "メンバーが選択されていません"
    end
  
    redirect_to public_group_path(@group)
  end

  def invite_existing
    @group = Group.find(params[:id])
  
    if params[:keyword].present?
      keyword = params[:keyword]
      @users = User.active.where("last_name LIKE ? OR first_name LIKE ? OR email LIKE ?", 
                          "%#{keyword}%", "%#{keyword}%", "%#{keyword}%")
                   .where.not(id: current_user.id)
    else
      @users = User.active.where.not(id: current_user.id)
    end
  end

  def select_group
    @target_user = User.find(params[:user_id])
    @groups = current_user.groups
  end

  def send_invite
    group = Group.find(params[:id])
    target_user = User.find(params[:user_id])

    if group.user_groups.exists?(user_id: target_user.id)
      redirect_to public_user_path(target_user), alert: "すでに招待済み、またはメンバーです。"
      return
    end

    group.user_groups.create!(user: target_user, status: :pending)
    redirect_to public_group_path(group), notice: "#{target_user.last_name} #{target_user.first_name}さんを招待しました。"
  end

  def confirm_withdraw
    @group = Group.find(params[:id])
    
  end
  
  def withdraw
    group = Group.find(params[:id])
    user_group = UserGroup.find_by(user: current_user, group: group)
  
    if user_group&.accepted?
      user_group.destroy
      flash[:notice] = "グループから退会しました。"
      redirect_to public_groups_path
    else
      flash[:alert] = "グループに参加していません。"
      redirect_to public_group_path(group)
    end
  end
  
  def edit
    @group = Group.find(params[:id])
  end

  def update
    @group = Group.find(params[:id])
    if @group.update(group_params)
      redirect_to public_group_path(@group), notice: "グループ情報を更新しました"
    else
      render :edit
    end
  end

  def destroy
    @group.destroy
    redirect_to public_groups_path, notice: "グループを削除しました"
  end



  private

  def set_group
    @group = Group.find(params[:id])
  end

  def group_params
    params.require(:group).permit(:name, :explanation)
  end

  def authorize_group_owner!
    unless @group.owner_id == current_user.id
      redirect_to public_groups_path,
                  alert: "このグループを編集する権限がありません。"
    end
  end
  
end