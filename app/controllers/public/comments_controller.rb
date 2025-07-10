class Public::CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group
  before_action :set_post

  def index
    @comments = @post.comments.order(created_at: :asc)
  end

  def new
    @comment = @post.comments.new
  end

  def create
    @comment = @post.comments.new(comment_params)
    @comment.user = current_user
    if @comment.save
      redirect_to public_group_post_comments_path(@group, @post), notice: "コメントを投稿しました"
    else
      render :new
    end
  end

  # その他edit, update, destroyも同様に@postの中で扱う

  private

  def set_group
    @group = Group.find(params[:group_id])
  end

  def set_post
    @post = @group.posts.find(params[:post_id])
  end

  def comment_params
    params.require(:comment).permit(:content)
  end
end