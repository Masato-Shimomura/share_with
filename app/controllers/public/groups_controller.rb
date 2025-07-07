class Public::GroupsController < ApplicationController
  before_action :authenticate_user!

  def index
    @groups = current_user.groups
  end

  def new
    @group = Group.new
  end
  
  def show
  end
  
  def edit
  end  

  def create
    @group = Group.new(group_params)
    @group.owner_id = current_user.id

    if @group.save
      current_user.user_groups.create(group: @group, status: :accepted)
      # 保存成功時のリダイレクトなど
      redirect_to public_groups_path, notice: "グループを作成しました"
    else
      # 保存失敗時の処理（エラーメッセージ表示など）
      render :new
  end  
end

private

  def group_params
    params.require(:group).permit(:name, :explanation)
  end
end

end