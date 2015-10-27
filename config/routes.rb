JellyfishOdl::Engine.routes.draw do
  resources :providers, only: [] do
    member do
      get :network_topology
      post :add_rule
      post :edit_rule
      delete :remove_rule
    end
  end
end
