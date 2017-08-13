Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get "/auth/:provider/callback" => "sessions#create"
  get "/auth/failure"            => "sessions#failure"

  match "/logout", to: "sessions#destroy", via: :all

  # root "static_pages#index"
  namespace :api do
    namespace :v1 do
      namespace :admin do
        resources :topics, except: [:delete, :edit] do
          resources :posts
        end

        root to: 'dashboard#index'
      end
    end
  end


  # mount_griddler

  # Mount attachinary
  mount Attachinary::Engine => "/attachinary"
end
