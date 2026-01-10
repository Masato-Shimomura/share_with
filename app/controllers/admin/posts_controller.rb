class Admin::PostsController < Admin::ApplicationController
  def index
    @posts = Post
               .includes(:user, :group)
               .order(created_at: :desc)

    if params[:keyword].present?
     @posts = @posts.where(
      "title LIKE ? OR body LIKE ?",
      "%#{params[:keyword]}%",
      "%#{params[:keyword]}%"
     )
    end
                         
  end
  

  def show
    @post = Post.find(params[:id])
  end

  def edit
    @post = Post.find(params[:id])
  end

  def update
    @post = Post.find(params[:id])
    if @post.update(post_params)
      redirect_to admin_post_path(@post), notice: "投稿を更新しました。"
    else
      render :edit
    end
  end

  def destroy
    @post = Post.find(params[:id])
    @post.destroy
    redirect_to admin_posts_path, notice: "投稿を削除しました。"
  end

  private

  def post_params
    params.require(:post).permit(:title, :body, :start_at, :end_at)
  end
end
