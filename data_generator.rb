# encoding: utf-8
require 'csv'
require 'json'
require 'yaml'
require 'mysql2'

module Datanames
  module Data

    def self.root_path(*args)
      File.join(File.dirname(__FILE__), *args)
    end

    DATA_FILE = root_path('data/nombres1922a2015conpp.csv')
    TOP_NAMES_PER_YEAR_SIZE = 10

    config = YAML.load(File.open(root_path("config.yml")))

    CLIENT = Mysql2::Client.new(:host => config['mysql']['host'], :username => config['mysql']['user'], :password => config['mysql']['password'], :database => "nombres")

    #
    #
    #
    def self.extract_data
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
          # Vaciar tabla
          CLIENT.query("TRUNCATE TABLE `nombres`")
          # TODO: cambiar esto por LOAD DATA INFILE para que sea mil veces más eficiente
          CLIENT.query("INSERT INTO nombres (name, quantity, year, gender, percentage) VALUES ('#{name}', #{quantity}, #{year}, '#{gender}', #{percentage})")
        rescue Exception => e
          puts e          
        end
      end

      years = (1922..2015).to_a
      decades = (1920..2010).step(10).to_a
      genders = ['f', 'm']

      # ---- START TOP DE NOMBRES POR ANIO ----
      years_folder = root_path('public', 'years')

      years.each do |y| 
        top_year = Hash.new { |h, k| h[k] = { f: [], m: [] } }
        
        genders.each do |g| 
          top_gender = []
          
          results_year = CLIENT.query("SELECT `name`, `quantity` FROM `nombres` WHERE year=#{y} AND gender='#{g}' ORDER BY quantity DESC LIMIT #{TOP_NAMES_PER_YEAR_SIZE}")
          results_year.each do |row|
            top_gender.push(row)
          end

          top_year[g] = top_gender
        end

        File.open(File.join(years_folder, "#{y}.json"), 'w') do |file|
          file.write(JSON.generate(top_year))
        end
      end
      # ---- END TOP DE NOMBRES POR ANIO -----

      # ---- START NOMBRES INDIVIDUALES ----
      names_folder = root_path('public', 'names')
      begin
        # Desactivar full group by
        CLIENT.query("SET GLOBAL sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''))")

        # Colapsar records duplicados
        CLIENT.query("DROP TABLE IF EXISTS `nombres_nodup`")
        CLIENT.query("CREATE TABLE `nombres_nodup` AS 
          SELECT `name`, `year`, `gender`, SUM(`percentage`) as `percentage`, SUM(`quantity`) as `quantity`
          FROM `nombres` GROUP BY `name`, `year`")
        CLIENT.query("ALTER TABLE `nombres_nodup` ADD KEY `nombres_nodup_name` (`name`)")
        CLIENT.query("ALTER TABLE `nombres_nodup` ADD KEY `nombres_nodup_year` (`year`)")
        CLIENT.query("ALTER TABLE `nombres_nodup` ADD UNIQUE KEY `nombres_nodup_unique_name_year` (`name`, `year`)")

        # Crear table de top 100k de nombres
        CLIENT.query("DROP TABLE IF EXISTS `nombres_top_100`")
        CLIENT.query("CREATE TABLE `nombres_top_100` AS 
          SELECT `name`, sum(`quantity`) as `sum_q`, `gender`
          FROM `nombres_nodup` GROUP BY `name` 
          ORDER BY `sum_q` DESC;")
        CLIENT.query("ALTER TABLE `nombres_top_100` ADD UNIQUE KEY `nombres_top_100_name` (`name`)")

        # Crear tablas de index de anios
        CLIENT.query("DROP TABLE IF EXISTS `anios`")
        CLIENT.query("CREATE TABLE `anios` AS SELECT DISTINCT `year` FROM `nombres`")
        CLIENT.query("ALTER TABLE `anios` ADD UNIQUE KEY `anios_year` (`year`)")

        # # Crear tabla con cruce de nombres con años para contar los casos 0
        CLIENT.query("DROP TABLE IF EXISTS `nombres_con_ceros`")
        CLIENT.query(
          "CREATE TABLE `nombres_con_ceros` AS 
          SELECT `nombres_top_100`.`name` as `name`, 
                 `nombres_top_100`.`gender` as `gender`,
                 `anios`.`year` as `year`,
                 SUM(COALESCE(`nombres_nodup`.`quantity`,0)) AS `quantity`, 
                 SUM(COALESCE(`nombres_nodup`.`percentage`,0)) as `percentage` 
          FROM `nombres_top_100` 
          JOIN `anios` 
          LEFT JOIN `nombres_nodup` 
          ON (`nombres_top_100`.`name`=`nombres_nodup`.`name` AND `anios`.`year`=`nombres_nodup`.`year`) 
          GROUP BY `nombres_top_100`.`name`, `anios`.`year`")
        
        results_distint_name = CLIENT.query("SELECT * FROM `nombres_con_ceros` ORDER BY `name` ASC, `year` ASC")
        last_name = ''
        nombre_lista = []

        results_distint_name.each do |row_name, index|
          curr_name = row_name['name']
          
          if curr_name == last_name or index == 0
            nombre_lista.push(row_name)
          elsif curr_name != last_name and index != 0
            File.open(File.join(names_folder, "#{last_name}.json"),'w') do |file|
              file.write(JSON.generate(nombre_lista))
            end
            nombre_lista = []
            nombre_lista.push(row_name)
          end

          if index == results_distint_name.size - 1
            File.open(File.join(names_folder, "#{curr_name}.json"), 'w') do |file|
              file.write(JSON.generate(nombre_lista))
            end
          end

          last_name = curr_name
        end

      rescue Exception => e
        puts e          
      end
      # ---- END NOMBRES INDIVIDUALES ----
      
      # ---- START TOP DE NOMBRES POR DECADA ----
      begin
        # Agregar columna de decada
        CLIENT.query("ALTER TABLE `nombres_con_ceros` ADD COLUMN `decade` INT")
        CLIENT.query("UPDATE TABLE `nombres_con_ceros` SET `decade` = (`year` DIV 10) * 10")

        decades.each do |decade|
          top_decade = Hash.new { |h, k| h[k] = { f: [], m: [] } }
          genders.each do |g|
            top_decade_gender = []
            results_decade = CLIENT.query("SELECT `name`, sum(`quantity`) as `quantity`, `decade` 
                                           FROM `nombres_con_ceros` 
                                           WHERE `gender` = '#{g}' AND `decade` = #{decade} 
                                           GROUP BY `name` 
                                           ORDER BY `decade` ASC, `quantity` DESC 
                                           LIMIT #{TOP_NAMES_PER_YEAR_SIZE}")
            results_decade.each do |row|
              top_decade_gender.push(row)
            end

            top_decade[g] = top_decade_gender
          end

          File.open(File.join(years_folder, "decada-#{decade}.json"), 'w') do |file|
            file.write(JSON.generate(top_decade))
          end
        end
      rescue Exception => e
        puts e
      end  
      # ---- END TOP DE NOMBRES POR DECADA ----

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

Datanames::Data::extract_data()
