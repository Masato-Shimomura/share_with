Rails.application.routes.draw do
  devise_for :admin, skip: [:registrations, :passwords], controllers: {
    sessions: "admin/sessions"
  }

  namespace :admin do
    root to: "homes#top"
    resources :groups, only: [:index, :show, :edit, :update, :destroy]
    resources :users, only: [:index, :show, :edit, :update, :destroy]
    resources :posts, only: [:index, :show, :edit, :update, :destroy]
  end

  devise_for :users, skip: [:passwords], controllers: {
    registrations: "public/registrations",
    sessions: 'public/sessions'
  }

  get "users" => redirect("/users/sign_up")

  root to: "public/homes#top"

  namespace :public do
    get 'about', to: 'homes#about'

    resources :users, only: [:index, :show, :edit, :update] do
      collection do
        get 'mypage'
        get 'confirm_withdraw'
        patch 'withdraw'
      end
    end

    resources :groups do
      # ✅ グループ未作成状態での招待（一覧検索など）用
      collection do
        get 'invite'
      end

      # ✅ グループ作成後の操作（ID必要）
      member do
        get 'invite'
        post 'invite'
        get 'calendar'
        get 'confirm_withdraw'
        post 'withdraw'
      end

      # ✅ 投稿とコメントはグループにネスト（必要）
      resources :posts do
        resources :comments, only: [:index, :new, :create, :edit, :update, :destroy]
      end
    end
  end
end