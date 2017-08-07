#!/usr/bin/ruby
class Anio
    def initialize(year, gender, quantity, percentage)
        @year, @gender, @quantity, @percentage = year, gender, quantity, percentage        
    end

    def year
        @year
    end

    def gender
        @gender
    end

    def quantity
        @quantity
    end

    def percentage
        @percentage
    end
end