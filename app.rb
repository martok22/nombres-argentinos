require 'sinatra/base'
require 'sinatra/config_file'
require 'json'
require root_path('helpers/assets')

class App < Sinatra::Base
  register Sinatra::ConfigFile
  helpers Helpers::Assets

  config_file 'config/app_config.yml'

  configure do
    set :views, root_path('views')
    set :public_folder, root_path('public')
    set :static_cache_control, [:public, max_age: 60 * 60 * 24]
    set :environment, settings.environment

    set :app_domain, settings.development? ? '127.0.0.1:9393' : "#{settings.host}:#{settings.port}"

    enable :static
  end

  configure :production, :development do
    enable :logging
  end

  not_found do
    erb :'not_found.html'
  end

  get %r{/(?:nombre/([^/]{2,120})(?:/(\d{4,4}))?)?} do |main_name, year|
    if settings.app_domain === request.env['HTTP_HOST']
      cache_control :public, :must_revalidate, max_age: 60 * 60 * 24
      names = (params[:others] || '').split(',')
      names.unshift(main_name) if main_name
      erb(:'index.html', layout: :'layout.html', locals: {
        names: names.map(&:strip),
        main_name: main_name,
        year: year ? year.to_i : ''
      })
    else
      redirect("http://#{settings.host}:#{settings.port}", 301)
    end
  end
end
