class Public::GroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group, only: [:show, :edit, :update, :destroy, :invite, :calendar, :confirm_withdraw, :withdraw]

  def index
    @groups = current_user.groups
  end

  def new
    @group = Group.new
  end

  def create
    @group = Group.new(group_params)
    @group.owner_id = current_user.id

    if @group.save
      current_user.user_groups.create(group: @group, status: :accepted)
      redirect_to public_groups_path, notice: "グループを作成しました"
    else
      render :new
    end
  end

  def show
    @members = @group.users
    @post = Post.new
    @posts = @group.posts.order(created_at: :desc)
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