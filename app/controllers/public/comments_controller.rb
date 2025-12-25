class Public::CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group_and_post
  before_action :set_comment, only: [:edit, :update, :destroy]
  before_action :authorize_comment!, only: [:edit, :update, :destroy]

  def index
    @comments = @post.comments.includes(:user).order(created_at: :asc)
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

  def edit
  end

  def update
    if @comment.update(comment_params)
      redirect_to public_group_post_comments_path(@group, @post), notice: "コメントを更新しました。"
    else
      render :edit
    end
  end

  def destroy
    @comment.destroy
    redirect_to public_group_post_comments_path(@group, @post), notice: "コメントを削除しました。"
  end


  private

  def set_group_and_post
    @group = Group.find(params[:group_id])
    @post = @group.posts.find(params[:post_id])
  end

  def set_comment
    @comment = @post.comments.find(params[:id])
  end

  def authorize_comment!
    redirect_to public_group_post_comments_path(@group, @post), alert: "編集・削除できるのは投稿者のみです。" unless @comment.user == current_user
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end