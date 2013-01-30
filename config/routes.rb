AngryTrash::Application.routes.draw do
  root to: "top#index"
  controller :blocks do
    resources :blocks, only: [ :create, :update, :destroy ]
    get '/blocks/destory_all', action: :destroy_all
  end
  resources :trashs, only: [ :update ]
  controller :canvases do
    resource :canvases, only: [ :update ]
  end
end
