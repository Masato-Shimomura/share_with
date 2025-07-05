Rails.application.routes.draw do
  devise_for :admin, skip: [:registrations, :passwords], controllers: {
  sessions: "admin/sessions"
}

namespace :admin do
  root to: "homes#top"
  resources :groups, only: [:index, :show, :edit, :update, :destroy]
  resources :users,  only: [:index, :show, :edit, :update, :destroy]
  resources :posts,  only: [:index, :show, :edit, :update, :destroy]
end

devise_for :users, skip: [:passwords], controllers: {
  registrations: "public/registrations",
  sessions: 'public/sessions'
}
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
    member do
      post 'invite'
      get 'calendar'
      get 'confirm_withdraw'
      post 'withdraw'
    end
  end

  resources :posts, only: [:index, :new, :create, :show, :edit, :update, :destroy] do
    resources :comments, only: [:index, :new, :create, :edit, :update, :destroy]
  end
 end
end