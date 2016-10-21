# encoding: utf-8
require 'csv'
require 'json'

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

    DATA_FILE = root_path('data/nombres1922a2015conpp.csv')
    TOP_NAMES_PER_YEAR_SIZE = 10  

    #
    #
    #
    def self.extract_data
      names = Hash.new { |h, k| h[k] = [] }
      years = Hash.new { |h, k| h[k] = { f: [], m: [] } }
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

        current_name_data = names[name].find { |nd| nd[:year] == year }

        if !current_name_data
          names[name] << { quantity: quantity, year: year, percentage: percentage, gender: gender }
        end

        current_decade = year.rounddown

        # Calculo de decadas
        decades_data = decades[current_decade][gender]

        name_index = decades_data.find_index { |item| item[:name] == name }
        if name_index
          decade_quantity = decades_data[name_index][:quantity] + quantity
          decades_data[name_index][:quantity] = decade_quantity
        else
          decades_data << { name: name, quantity: quantity }
        end
        decades_data.sort_by! { |name| name[:quantity] }
      
        # Calculo de años
        year_data = years[year][gender]

        if year_data.size < TOP_NAMES_PER_YEAR_SIZE
          year_data << { name: name, quantity: quantity }
        else
          lowest_name = year_data.shift
          if lowest_name[:quantity] < quantity
            year_data.push({ name: name, quantity: quantity })
          else
            year_data.push(lowest_name)
          end
        end
        year_data.sort_by! { |name| name[:quantity] }
      end

      # Seleccionar solo el top 
      decades.each do |decade, genders|
        genders.each do |gender, array|
          decades[decade][gender] = array.last(TOP_NAMES_PER_YEAR_SIZE)
        end
      end

      return [names, years, decades]
    end

    #
    #
    #
    def self.export_data
      names, years, decades = extract_data

      names_folder = root_path('public', 'names')
      names.each do |name, name_data|
        File.open(File.join(names_folder, "#{name}.json"), 'w') do |file|
          file.write(JSON.generate(name_data))
        end
      end

      years_folder = root_path('public', 'years')
      years.each do |year, year_data|
        File.open(File.join(years_folder, "#{year}.json"), 'w') do |file|
          file.write(JSON.generate(year_data))
        end
      end

      decades.each do |decade, decade_data|
        File.open(File.join(years_folder, "decada-#{decade}.json"), 'w') do |file|
          file.write(JSON.generate(decade_data))
        end
      end
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
