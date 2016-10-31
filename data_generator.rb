# encoding: utf-8
require 'csv'
require 'json'
require 'yaml'
require 'mysql2'

class Numeric
  def roundup(nearest=10)
    self % nearest == 0 ? self : self + nearest - (self % nearest)
  end
  def rounddown(nearest=10)
    self % nearest == 0 ? self : self - (self % nearest)
  end
end 

module Datanames
  module Data

    def self.root_path(*args)
      File.join(File.dirname(__FILE__), *args)
    end

    DATA_FILE = root_path('data/sample_2013_2014.csv')
    TOP_NAMES_PER_YEAR_SIZE = 10

    config = YAML.load(File.open(root_path("config.yml")))

    CLIENT = Mysql2::Client.new(:host => config['mysql']['host'], :username => config['mysql']['user'], :password => config['mysql']['password'], :database => "nombres")
    #
    #
    #
    def self.extract_data
      names = Hash.new { |h, k| h[k] = [] }
      decades = Hash.new { |h, k| h[k] = { f: [], m: [] } }

      # CSV columns
      #   0: Name
      #   1: Quantity
      #   2: Year
      #   3: Gender
      #   4: Percentage
      CSV.foreach(DATA_FILE, encoding:'utf-8') do |row|
        # Print cada 100000
        if $. % 100000 == 0
          puts $.
        end
        
        name = format_name(row[0])
        year = row[2].to_i
        quantity = row[1].to_i
        percentage = row[4].to_f
        gender = case row[3]
                 when 'F' then :f
                 when 'M' then :m
                 else raise "Invalid gender: #{row[1].inspect}"
                 end

        begin
          CLIENT.query("INSERT INTO nombres_sample (name, quantity, year, gender, percentage) VALUES ('#{name}', #{quantity}, #{year}, '#{gender}', #{percentage})")
        rescue Exception => e
          puts e          
        end
      end

      # years = (1922..2015).to_a
      
      # # ---- START TOP DE NOMBRES POR ANIO ----
      # genders = ['f', 'm']
      # years_folder = root_path('public', 'years')

      # years.each do |y| 
      #   top_year = Hash.new { |h, k| h[k] = { f: [], m: [] } }
        
      #   genders.each do |g| 
      #     top_gender = []
          
      #     results_year = CLIENT.query("SELECT `name`, `quantity` FROM `nombres` WHERE year=#{y} AND gender='#{g}' ORDER BY quantity DESC LIMIT #{TOP_NAMES_PER_YEAR_SIZE}")
      #     results_year.each do |row|
      #       top_gender.push(row)
      #     end

      #     top_year[g] = top_gender
      #   end

      #   File.open(File.join(years_folder, "#{y}.json"), 'w') do |file|
      #     file.write(JSON.generate(top_year))
      #   end
      # end

      # ---- END TOP DE NOMBRES POR ANIO -----

      # ---- START TOP DE NOMBRES POR DECADA ----
      

      # ---- END TOP DE NOMBRES POR DECADA ----


      # query distint de nombres
      # "SELECT DISTINCT name FROM `nombres`"
      
      return [names, years, decades]
    end

    #
    #
    #
    def self.export_data
      names, years, decades = extract_data

      # names_folder = root_path('public', 'names')
      # names.each do |name, name_data|
      #   File.open(File.join(names_folder, "#{name}.json"), 'w') do |file|
      #     file.write(JSON.generate(name_data))
      #   end
      # end

      # years_folder = root_path('public', 'years')
      # years.each do |year, year_data|
      #   File.open(File.join(years_folder, "#{year}.json"), 'w') do |file|
      #     file.write(JSON.generate(year_data))
      #   end
      # end

      # decades.each do |decade, decade_data|
      #   File.open(File.join(years_folder, "decada-#{decade}.json"), 'w') do |file|
      #     file.write(JSON.generate(decade_data))
      #   end
      # end
    end

    #
    #
    #
    def self.format_name(name)
      replacements = [
        [/Á/, "a"],
        [/É/, "e"],
        [/Í/, "i"],
        [/Ó/, "o"],
        [/Ú/, "u"],
        [/Ñ/, "n"],
        [/( de los| del| de las| de la| de)(\s.*)?/, " "],
        [/[^\sa-zA-Z\d]+/, " "],
        [/\s+/, "_"],
        [/^_+/, ""],
        [/_+$/, ""]
      ]
      replacements.inject(name.strip.downcase) do |str, (from, to)|
        str.gsub(from, to)
      end
    end

  end
end

Datanames::Data::export_data()
