#!/usr/bin/ruby
require 'yaml'

class Nombre
    @@config = YAML.load_file('config/mysql.conf')

    def initialize(nombre)
        @nombre = nombre
    end

    def nombre
        @nombre
    end

    def get_all
        mysql_client = Mysql2::Client.new(:host => @@config["host"], :username => @@config["username"], :password => @@config["password"], :database => "nombres")
        results = mysql_client.query("SELECT * FROM cruce_nombres_anios WHERE name = '#{@nombre}'", :symbolize_keys => true)
        mysql_client.close

        all_years = []

        results.each do |row|
            all_years = all_years << row.select {|k, v| [:gender, :percentage, :year, :quantity].include?(k) }
        end

        all_years.to_json
    end
end