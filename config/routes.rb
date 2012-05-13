Rails.application.routes.draw do

  resource :session

  match 'login', :to => 'sessions#new', :as => 'login'
  match 'logout', :to => 'sessions#destroy', :as => 'logout'

  if ActiveRecord::Agent.activation_class
    match 'activate/:activation_code', :to => "#{ActiveRecord::Agent.activation_class.to_s.tableize}#activate",
      :as => 'activate', :activation_code => nil
    match 'lost_password', :to => "#{ActiveRecord::Agent.activation_class.to_s.tableize}#lost_password",
      :as => 'lost_password'
    match 'reset_password/:reset_password_code', :to => "#{ActiveRecord::Agent.activation_class.to_s.tableize}#reset_password",
      :as => 'reset_password', :reset_password_code => nil
  end

  resources :tags

  resource :site do
    if Site.table_exists?
# TODO
      with_options :requirements => { :site_id => Site.current.id } do
        resources :performances
        resources *ActiveRecord::Resource.symbols
      end
#
    end
  end

  resources *( ( ActiveRecord::Resource.symbols |
                 ActiveRecord::Content.symbols  |
                 ActiveRecord::Agent.symbols ) -
                 ActiveRecord::Container.symbols )

  ActiveRecord::Container.symbols.each do |container_sym|
    next if container_sym == :sites
    resources container_sym do
      resources(*container_sym.to_class.contents)
      resources :sources do
        get :import, :as => :member
      end
      resources :tags
    end
  end
  resources :sources do
    get :import, :as => :member
  end

  resources :logos

  resources(*(ActiveRecord::Logoable.symbols - Array(:sites))) do
    resource :logo
  end

  resources :roles
  resources :invitations do
    get :accept, :as => :member
  end

  resources(*ActiveRecord::Stage.symbols - Array(:sites)) do
    resources :performances
    resources :invitations
    resources :join_requests
  end

  resources :performances
end
