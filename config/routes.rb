Rails.application.routes.draw do
  get "reservations/index"
  get "reservations/create"
  get "users/show"
  get "users/edit"
  get "users/update"
  get "rooms/index"
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"
  root to: "rooms#index" 
  resources :users, only: [:show, :edit, :update]
  resources :rooms do
    collection do
      get 'posts'   # 自分が作成した施設一覧ページ用
      get 'search'  # 検索結果ページ用
    end
    resources :reservations, only: [:create]
  end

  # 自分の予約一覧用
  resources :reservations, only: [:index, :create, :edit, :update, :destroy] do
    collection do
      post 'confirm'
    end
  end
end