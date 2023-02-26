Rails.application.routes.draw do

  root 'static_pages#top'
  get '/signup', to: 'users#new'  
  get 'attendant_employees', to: 'users#attendant_employees'

  # ログイン機能
  get    '/login', to: 'sessions#new'
  post   '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  # 拠点情報

  resources :bases do
    member do
      get 'edit_base_info'
      patch 'update_base_info'
    end
  end

  resources :users do
    collection { post :import }    
    member do
      get 'edit_basic_info'
      patch 'update_basic_info'
      get 'attendances/edit_one_month'
      patch 'attendances/update_one_month'
      get 'working'
      get 'show_read_only'
      get 'attendances/log_attendant'
    end
    resources :attendances do
      get 'edit_overwork_request'
      patch 'update_overwork_request'
      get 'edit_monthly_request'
      
      collection do
        get 'edit_overwork_info'
        patch 'update_overwork_info'
        get 'edit_daily_info'
        patch 'update_daily_info'        
        get 'edit_monthly_info'
        patch 'update_monthly_info'        
        #patch 'edit_overwork_permission'
        #patch 'edit_daily_permission'
        #patch 'edit_monthly_permission'
      end
    end
  end
end
