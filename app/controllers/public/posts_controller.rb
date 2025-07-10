class Public::PostsController < ApplicationController
  class Public::PostsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_group
    before_action :set_post, only: [:show, :edit, :update, :destroy]
  
    def index
      @posts = @group.posts.order(created_at: :desc)
    end
  
    def new
      @post = @group.posts.new
    end
  
    def create
      @post = @group.posts.new(post_params)
      @post.user = current_user
      if @post.save
        redirect_to public_group_post_path(@group, @post), notice: "投稿を作成しました"
      else
        # 失敗時はグループ詳細に戻ることも検討してください
        render :new
      end
    end
  
    def show
    end
  
    def edit
    end
  
    def update
      if @post.update(post_params)
        redirect_to public_group_post_path(@group, @post), notice: "投稿を更新しました"
      else
        render :edit
      end
    end
  
    def destroy
      @post.destroy
      redirect_to public_group_posts_path(@group), notice: "投稿を削除しました"
    end
  
    private
  
    def set_group
      @group = Group.find(params[:group_id])
    end
  
    def set_post
      @post = @group.posts.find(params[:id])
    end
  
    def post_params
      params.require(:post).permit(:title, :body, :start_at, :end_at)
    end
  end