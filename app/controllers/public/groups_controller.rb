class Public::GroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group, only: [:show, :edit, :update, :destroy, :calendar, :confirm_withdraw, :withdraw]

  def accept_invitation
    user_group = current_user.user_groups.find_by(group_id: params[:id], status: :pending)
    if user_group
      user_group.update(status: :accepted)
      flash[:notice] = "グループに参加しました"
    else
      flash[:alert] = "有効な招待が見つかりませんでした"
    end
    redirect_to mypage_public_users_path  # ← 適切な遷移先に変更OK
  end
  
  # 招待辞退
  def reject_invitation
    user_group = current_user.user_groups.find_by(group_id: params[:id], status: :pending)
    if user_group
      user_group.destroy
      flash[:notice] = "招待を辞退しました"
    else
      flash[:alert] = "辞退する招待が見つかりませんでした"
    end
    redirect_to mypage_public_users_path  # ← 適切な遷移先に変更OK
  end

  def index
    @groups = current_user.groups
  end

  def new
    @group = Group.new

    # 招待されたユーザーIDをparamsで受け取って保持
   if params[:invited_user_ids].present?
    # 配列に変換（int型にする）
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
      @users = User.where("last_name LIKE ? OR first_name LIKE ? OR email LIKE ?", 
                          "%#{keyword}%", "%#{keyword}%", "%#{keyword}%")
                   .where.not(id: current_user.id)
    else
      @users = User.where.not(id: current_user.id)
    end
  end
  
  # POST /public/groups/:id/invite
  def send_invites
    @group = Group.find(params[:id])
    
    if params[:invited_user_ids].present?
      params[:invited_user_ids].each do |user_id|
        # すでに存在しないかチェック
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
      @users = User.where("last_name LIKE ? OR first_name LIKE ? OR email LIKE ?", 
                          "%#{keyword}%", "%#{keyword}%", "%#{keyword}%")
                   .where.not(id: current_user.id)
    else
      @users = User.where.not(id: current_user.id)
    end
  end

  def confirm_withdraw
    @group = Group.find(params[:id])
    # viewだけ表示（確認メッセージ含め）
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

  # 例: 招待・カレンダー・退会などのアクションも必要に応じてここに追加

  private

  def set_group
    @group = Group.find(params[:id])
  end

  def group_params
    params.require(:group).permit(:name, :explanation)
  end
end