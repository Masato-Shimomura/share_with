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

    resources :user_groups, only: [] do
      member do
        patch :accept
        delete :reject
      end
    end

    resources :groups do
      collection do
        get 'invite'  # 新規作成前の招待ページ
      end

      member do
        post 'accept_invitation'
        delete 'reject_invitation'
        get 'invite_existing'  # 既存グループへの招待ページ
        post 'send_invites'    # 招待送信アクション
        get 'calendar'
        get 'confirm_withdraw'
        delete 'withdraw'
      end

      # ここで posts と comments を groups にネスト
      resources :posts do
        resources :comments, only: [:index, :new, :create, :edit, :update, :destroy]
      end
    end
  end
end