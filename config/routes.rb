Keikoku::Application.routes.draw do
  
  get '/alerts/find/'
  resources :alerts, except: [:new, :edit] do
    resources :alert_stats, only: [:index]
  end

end
