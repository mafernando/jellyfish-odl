JellyfishOdl::Engine.routes.draw do
  resources :providers, only: [] do
    member do
      get :network_topology
      get :add_rule
      get :edit_rule
      get :remove_rule
    end
  end
end
