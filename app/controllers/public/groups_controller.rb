class Public::GroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group, only: [:show, :edit, :update, :destroy, :calendar, :confirm_withdraw, :withdraw]

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
    @members = @group.users
    @post = Post.new
    @posts = @group.posts.order(created_at: :desc)
  end

  def invite
    # 検索用キーワード
    if params[:keyword].present?
      keyword = params[:keyword]
      @users = User.where("last_name LIKE ? OR first_name LIKE ? OR email LIKE ?", 
                          "%#{keyword}%", "%#{keyword}%", "%#{keyword}%")
                   .where.not(id: current_user.id)
    else
      @users = User.where.not(id: current_user.id)
    end
  end

  def edit
  end

  def update
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