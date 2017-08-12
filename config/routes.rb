Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get "/auth/:provider/callback" => "sessions#create"
  get "/auth/failure"            => "sessions#failure"

  match "/logout", to: "sessions#destroy", via: :all

  # root "static_pages#index"
  namespace :api do
    namespace :v1 do
      namespace :admin do

    # Extra topic Routes
        get 'topics/update_topic' => 'topics#update_topic', as: :update_topic, defaults: {format: 'js'}
        post 'topics/merge_tickets' => 'topics#merge_tickets', as: :merge_tickets
        patch 'topics/update_tags' => 'topics#update_tags', as: :update_topic_tags
        get 'topics/update_multiple' => 'topics#update_multiple_tickets', as: :update_multiple_tickets
        get 'topics/assign_agent' => 'topics#assign_agent', as: :assign_agent
        get 'topics/toggle_privacy' => 'topics#toggle_privacy', as: :toggle_privacy
        get 'topics/:id/toggle' => 'topics#toggle_post', as: :toggle_post
        get 'topics/assign_team' => 'topics#assign_team', as: :assign_team
        get 'topics/unassign_team' => 'topics#unassign_team', as: :unassign_team
        post 'topics/:topic_id/split/:post_id' => 'topics#split_topic', as: :split_topic
        get 'shortcuts' => 'topics#shortcuts', as: :shortcuts

        resources :categories do
          resources :docs, except: [:index, :show]
        end


        resources :internal_categories, only: [:index, :show] do
          resources :internal_docs, only: :show
        end

        resources :docs, except: [:index, :show]

        resources :images, only: [:create, :destroy]
        resources :forums# , except: [:index, :show]
        resources :users
        scope 'settings' do
          resources :api_keys, except: [:show, :edit, :update]
          resources :groups
        end
        resources :topics, except: [:delete, :edit] do
          resources :posts
        end
        resources :posts
        get '/posts/:id/raw' => 'posts#raw', as: :post_raw
        get '/dashboard' => 'dashboard#index', as: :dashboard
        get '/reports/team' => 'reports#team', as: :team_reports
        get '/reports/groups' => 'reports#groups', as: :group_reports
        get '/reports' => 'reports#index', as: :reports

        root to: 'dashboard#index'
      end
    end
  end


  # mount_griddler

  # Mount attachinary
  mount Attachinary::Engine => "/attachinary"
end
