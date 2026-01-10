Rails.application.routes.draw do
  devise_for :admin, skip: [:registrations, :passwords], controllers: {
    sessions: "admin/sessions"
  }

  namespace :admin do
    root to: "homes#top"
    resources :groups, only: [:index, :show, :edit, :update, :destroy]
    resources :users, only: [:index, :show, :edit, :update, :destroy]
    resources :posts, only: [:index, :show, :edit, :update, :destroy]
    resources :comments, only: [:index, :show, :destroy]
  end

  devise_for :users, skip: [:passwords], controllers: {
    registrations: "public/registrations",
    sessions: 'public/sessions'
  }

  get "users" => redirect("/users/sign_up")

  root to: "public/homes#top"

  namespace :public do
    get 'about', to: 'homes#about'

    get "posts/search", to: "posts#search", as: "search_public_posts"

    resources :users, only: [:index, :show, :edit, :update] do
      collection do
        get 'mypage'
        get 'confirm_withdraw'
        delete 'withdraw'
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
        get 'invite'  
        get 'select_group', to: 'groups#select_group'
      end

      member do
        post 'accept_invitation'
        delete 'reject_invitation'
        get 'invite_existing'  
        post 'send_invites'   
        get 'calendar'
        get 'confirm_withdraw'
        delete 'withdraw'
        post 'send_invite', to: 'groups#send_invite'
      end

      resources :posts do
        resources :comments, only: [:index, :new, :create, :edit, :update, :destroy]
      end
    end
  end
end