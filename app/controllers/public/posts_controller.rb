class Public::PostsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_group, except: [:search]
    before_action :ensure_group_member!, except: [:search]
    before_action :set_post, only: [:show, :edit, :update, :destroy]
    before_action :authorize_post!, only: [:edit, :update, :destroy]
  
    def index
      @posts = @group.posts.order(created_at: :desc)
    end

    def search
      @keyword = params[:keyword]
    
      if @keyword.present?
        group_ids = current_user.groups.pluck(:id)
    
        @posts = Post
                   .where(group_id: group_ids)
                   .where("title LIKE ? OR body LIKE ?", "%#{@keyword}%", "%#{@keyword}%")
                   .includes(:group, :user)
      else
        @posts = Post.none
      end
    end
  
    def new
      @post = @group.posts.new
    end
  
    def create
      @post = @group.posts.new(post_params)
      @post.user = current_user
      if @post.save
        redirect_to public_group_path(@group), notice: "投稿を作成しました"
      else
        
        @posts = @group.posts.includes(:user).order(created_at: :desc)
        @members = @group.user_groups.where(status: :accepted).includes(:user).map(&:user)
        render "public/groups/show"
      end
    end
  
    def show
    end
  
    def edit
    end
  
    def update
      if @post.update(post_params)
        redirect_to public_group_post_path(@group), notice: "投稿を更新しました"
      else
        render :edit
      end
    end
  
    def destroy
      @post.destroy
      redirect_to public_group_path(@group), notice: "投稿を削除しました"
    end
  
    private
  
    def set_group
      @group = Group.find(params[:group_id])
    end
  
    def set_post
      @post = @group.posts.find(params[:id])
    end

    def ensure_group_member!
      return if @group.owner_id == current_user.id
      is_member = @group.user_groups.exists?(user_id: current_user.id, status: :accepted)
      unless is_member
        redirect_to public_groups_path, alert: "このグループのメンバーのみアクセスできます。"
      end
    end
  
    def post_params
      params.require(:post).permit(:title, :body, :start_at, :end_at)
    end

    def authorize_post!
      unless @post.user == current_user
        redirect_to public_group_path(@group), alert: "編集・削除できるのは投稿者のみです。"
      end
    end
  end