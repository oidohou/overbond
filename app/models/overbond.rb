
class Overbond < ApplicationRecord
    include Overbonds::OutputFormatter



    self.inheritance_column = :_type_disabled
    enum type: {corporate: "corporate", government: "government"}

    attr_accessor :corporate_bonds , :government_bonds

    SPREAD_TO_BENCHMARK_HEADERS = %w(bond benchmark spread_to_benchmark).freeze.map(&:freeze)
    SPREAD_TO_CURVE_HEADERS     = %w(bond spread_to_curve).freeze.map(&:freeze)
    SPREAD_FORMAT = '%.2f'.freeze

    def self.import
        csv_text = File.read(Rails.root.join('lib', 'seeds', 'sample_input.csv'))
        CSV.parse(csv_text, headers: true) do |row|
            Overbond.create! row.to_hash
        end
    end

    def self.spread_to_benchmark
        corporate_bonds =  Overbond.where(type: "corporate")
        benchmarks = corporate_bonds.map do |corporate_bond|
            benchmark = closest_government_bond(corporate_bond)
            spread    = delta(corporate_bond.yield, benchmark.yield)
        
            [corporate_bond.id, benchmark.id, spread]
        end
    
        to_csv(SPREAD_TO_BENCHMARK_HEADERS, benchmarks)
    end
    
    def self.spread_to_curve
        corporate_bonds =  Overbond.where(type: "corporate")
        curves = corporate_bonds.map do |corporate_bond|
            lower, upper = closest_government_bonds(corporate_bond)
            spread = interpolated_yield(corporate_bond, lower, upper)
      
            [corporate_bond.id, spread]
          end
      
          to_csv(SPREAD_TO_CURVE_HEADERS, curves)
    end

    
    private
    
    def self.closest_government_bond(corporate_bond)
        government_bonds  = Overbond.where(type: "government")
        government_bonds.min_by do |bond|
            delta(bond.term, corporate_bond.term)
        end
    end

    def self.closest_government_bonds(corporate_bond)
        government_bonds  = Overbond.where(type: "government")
        lower_bonds, upper_bonds = government_bonds.partition do |bond|
            bond.term <= corporate_bond.term
        end

        [lower_bonds.max_by(&:term), upper_bonds.min_by(&:term)]
    end

    def self.interpolated_yield(corporate, lower, upper)
        delta(
          corporate.yield,
          (
            (
              (corporate.term - lower.term) * upper.yield +
              (upper.term - corporate.term) * lower.yield
            ) / (upper.term - lower.term)
          )
        )
      end
    
      def self.delta(minEnd, subEnd)
        (minEnd - subEnd).abs
      end


      

      def self.to_csv(headers, rows)
        CSV.generate(headers: :first_row) do |csv|
          csv << headers
          rows.each do |row|
            csv << with_printable_spread(row)
          end
        end
      end
  
      def self.with_printable_spread(row)
        row[-1] = sprintf(SPREAD_FORMAT, row.last)
        row
      end

    def corporate_bonds 
        @corporate_bonds =  Overbond.where(type: "corporate")
    end
    def government_bonds
        @government_bonds  = Overbond.where(type: "government")
    end
end
