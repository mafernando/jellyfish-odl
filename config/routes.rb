JellyfishOdl::Engine.routes.draw do
  resources :providers, only: [] do
    member do
      get :network_topology
    end
  end
end
