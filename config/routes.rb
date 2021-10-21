Spree::Core::Engine.add_routes do
  # Add your extension routes here
  namespace :api, defaults: { format: 'json' } do
    namespace :v2 do
  	  namespace :storefront do
  	  	resources :return_authorization_reasons, only: [:index]
  	  	resources :return_authorizations, only: [:create]
  	  end
  	end
  end			
end
