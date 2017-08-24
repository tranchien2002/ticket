Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get "/auth/:provider/callback" => "user_sessions#create"
  get "/auth/failure"            => "user_sessions#failure"

  match "/logout", to: "user_sessions#destroy", via: :all

  # root "static_pages#index"
  namespace :api, defaults: {format: :json} do
    namespace :v1 do
      namespace :admin do
        resources :topics, except: [:destroy, :edit] do
          put :update_topic, on: :collection
          get :dashboard, on: :collection
          put :assign_agent, on: :collection
          get :search, on: :collection
          resources :posts
        end

        get 'search/topic_search' => 'search#topic_search', as: :topic_search

        root to: 'dashboard#index'
      end
    end
  end


  # mount_griddler

  # Mount attachinary
  mount Attachinary::Engine => "/attachinary"
end
