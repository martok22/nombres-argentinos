require 'sinatra/base'
require 'sinatra/config_file'
require 'json'
require 'mysql2'
require root_path('helpers/assets')

class App < Sinatra::Base
  register Sinatra::ConfigFile
  helpers Helpers::Assets

  config_file 'config/app_config.yml'
  NOMBRES_DEFAULT = ["Emilia", "Benjamin"]

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

  get %r{/(?:nombre/([^/]{2,120})(?:/(\d{4,4}))?)?$} do |main_name, year|
    if settings.app_domain === request.env['HTTP_HOST']
      cache_control :public, :must_revalidate, max_age: 60 * 60 * 24
      
      # Otros nombres para comparar / Sacamos whitespace
      other_names = (params[:others] || '').split(',').map(&:strip)

      # Asignar default de nombres
      if main_name
        default = false
      else
        default = true
        main_name = NOMBRES_DEFAULT[0]
        other_names = [NOMBRES_DEFAULT[1]]
      end

      # Buscar data de todos los nombres (el principal y el/los otros)
      main_name_data = Nombre.new(main_name).get_all
      other_names_data = []
      other_names.each do |other_name|
        other_names_data << Nombre.new(other_name).get_all
      end

      erb(:'index.html', layout: :'layout.html', locals: {
        default: default,
        main_name: main_name,
        main_name_data: main_name_data,
        other_names: other_names,
        other_names_data: other_names_data,
        year: year ? year.to_i : ''
      })
    else
      redirect("http://#{settings.host}:#{settings.port}", 301)
    end
  end
end

require_relative('models/nombre.rb')