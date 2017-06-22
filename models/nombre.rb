#!/usr/bin/ruby
require 'yaml'

class Nombre
    @@config = YAML.load_file('config/mysql.conf')
    @@mysql_client = Mysql2::Client.new(:host => @@config["host"], :username => @@config["user"], :password => @@config["password"], :database => "nombres")

    def initialize(nombre)
        @nombre = nombre
    end

    def nombre
        @nombre
    end

    def get_all
        mysql_client = @@mysql_client
        results = mysql_client.query("SELECT * FROM cruce_nombres_anios WHERE name = '#{@nombre}'", :symbolize_keys => true)

        all_years = []

        results.each do |row|
            all_years = all_years << row.select {|k, v| [:gender, :percentage, :year, :quantity].include?(k) }
        end

        all_years.to_json
    end
end

require_relative('anio.rb')