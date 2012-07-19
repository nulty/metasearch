Metasearch::Application.routes.draw do
  

  get "comparison/single_query"

  get "comparison/summary"

  get "single_query/summary"

  #get "comparison/single_query(/:engine/:query)"
  resources :googles

  get "/googlesearch" => "googles#search", :as => :googlestore
  match "/googlesearch" => "googles#store", :via => [:get, :post], :as => :googlestore
  
  post "/pages" => "results#store", :as => :store

  resources :results


	controller :pages do
	  post '/pages' => 'results#store', :as => :store
		get "/pages" => "pages#index"
		get "pages/cluster" => :cluster, :as => :cluster
		get "/searchresults" => "pages#results", :as => :searchresults#match '/pages' => 'pages#results'
		get "/aggregated" => "pages#aggregated"
		
  end
  	
	controller :bing do
		#get '/bing' #=> 'bing#results', :as => :bing
		#match '/bing' => redirect("/bing")
		get '/bing' => 'bing#results'#:results, :as => :bing
		post '/bingresults' => 'bing#results', :as => :bing_results
		#match '/bing' => redirect("/bing")
	end

	controller :blekko do
		get "blekko/results"
		#post 'blekko#results' => :results
		match '/blekko' => 'blekko#results', :as => :blekko
	end
	
	controller :entireweb do
		get "entireweb/results"
		#post 'pages#search' => :results
		match '/entireweb' => 'entireweb#results', :as => :entireweb
	end

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => "pages#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
