class Overbond < ApplicationRecord
    include Overbonds::OutputFormatter

    self.inheritance_column = :_type_disabled
    enum type: {corporate: "corporate", government: "government"}

    attr_accessor :corporate_bonds , :government_bonds

    SPREAD_TO_BENCHMARK_HEADERS = %w(bond benchmark spread_to_benchmark).freeze.map(&:freeze)
    SPREAD_TO_CURVE_HEADERS     = %w(bond spread_to_curve).freeze.map(&:freeze)
    

    def self.import
        csv_text = File.read(Rails.root.join('lib', 'seeds', 'sample_input.csv'))
        CSV.parse(csv_text, headers: true) do |row|
            Overbond.create! row.to_hash
        end
    end

    def self.initialize
        @corporate_bonds =  Overbond.where(type: "corporate")
        @government_bonds  = Overbond.where(type: "government")
            
    end

    def self.spread_to_benchmark
        benchmarks = @corporate_bonds.map do |corporate_bond|
            benchmark = closest_government_bond(corporate_bond)
            spread    = delta(corporate_bond.yield_spread, benchmark.yield_spread)
        
            [corporate_bond.id, benchmark.id, spread]
        end
    
        to_csv(headers: SPREAD_TO_BENCHMARK_HEADERS, rows: benchmarks)
    end
    
    def self.spread_to_curve
        curves = @corporate_bonds.map do |corporate_bond|
            lower, upper = closest_government_bonds(@corporate_bond)
            spread = interpolated_yield(corporate_bond, lower, upper)
      
            [corporate_bond.id, spread]
          end
      
          to_csv(headers: SPREAD_TO_CURVE_HEADERS, rows: curves)
    end

    
    private
    
    def closest_government_bond(corporate_bond)
        government_bonds.min_by do |bond|
            delta(bond.term, corporate_bond.term)
        end
    end

    def closest_government_bonds(corporate_bond)
        lower_bonds, upper_bonds = government_bonds.partition do |bond|
            bond.term <= corporate_bond.term
        end

        [lower_bonds.max_by(&:term), upper_bonds.min_by(&:term)]
    end

    def interpolated_yield(corporate, lower, upper)
        delta(
          corporate.yield_spread,
          (
            (
              (corporate.term - lower.term) * upper.yield_spread +
              (upper.term - corporate.term) * lower.yield_spread
            ) / (upper.term - lower.term)
          )
        )
      end
    
      def delta(minEnd, subEnd)
        (minEnd - subEnd).abs
      end
end
