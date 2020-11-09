Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.\u{1f50e}
  post 'api/process-logs', to: 'api/process_logs#create'
  # resources :'process_logs'
end
