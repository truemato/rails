Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :stocks, only: [:index, :show, :create] do
        collection do
          delete :destroy
        end
      end
      resources :sales, only: [:index, :create]
    end
  end
end
