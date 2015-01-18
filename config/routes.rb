Rails.application.routes.draw do
  root "static_pages#home"

  get "static_pages/home"
  get "options", to: "static_pages#options"
end
