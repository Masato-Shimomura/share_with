class Admin::GroupsController < Admin::ApplicationController
  before_action :set_group, only: [:show, :edit, :update, :destroy]

  def index
    @keyword = params[:keyword]
  
    @groups =
      if @keyword.present?
        Group
          .where("name LIKE ?", "%#{@keyword}%")
          .includes(:owner, :users, :posts)
          .order(created_at: :desc)
      else
        Group
          .includes(:owner, :users, :posts)
          .order(created_at: :desc)
      end
  end  
  
  def show
    @group = Group.find(params[:id])
  end

  def edit
    @group = Group.find(params[:id])
  end

  def update
    @group = Group.find(params[:id])
    if @group.update(group_params)
      redirect_to admin_group_path(@group), notice: "グループを更新しました。"
    else
      render :edit
    end
  end

  def destroy
    @group = Group.find(params[:id])
    @group.destroy
    redirect_to admin_groups_path, notice: "グループを削除しました。"
  end

  private

  def set_group
    @group = Group.find(params[:id])
  end  

  def group_params
    params.require(:group).permit(:name, :explanation)
  end
end
