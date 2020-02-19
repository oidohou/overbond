require 'test_helper'
require 'csv'

class OverbondTest < ActiveSupport::TestCase

  test 'test_extracts_the_corporate_bonds' do
    corporate_bonds = Overbond.corporate_bonds
    corporate_bonds.each do |bond|
      assert_equal "corporate", bond.type
    end
  end

  test 'test_extracts_the_government_bonds' do
    government_bonds = Overbond.government_bonds
    government_bonds.each do |bond|
      assert_equal "government", bond.type
    end
  end


  test 'test_spread_to_curve_for_corporate_bond_term_equal_to_government_bond_term' do
    same_term = '12'
    @overbond = Overbond.new([
      {bond: 'C1', type: "corporate", term: same_term, yield: 5.30},
      {bond: 'G1', type: "government", term: 10.3, yield: 4.80},
      {bond: 'G2', type: "government", term: same_term, yield: 5.70},
      {bond: 'G3', type: "government", term: 15.7, yield: 6.90},
    ])

    assert_match 'C1,0.40', Overbond.spread_to_curve
  end

  

  test 'test_spread_to_benchmark_calculates_expected_values_from_sample_input' do
    output = <<-CSV.gsub(' ', '')
      bond,benchmark,spread_to_benchmark
      C1,G1,1.60
      C2,G2,1.50
      C3,G3,2.00
      C4,G3,2.90
      C5,G4,0.90
      C6,G5,1.80
      C7,G6,2.50
    CSV

    assert_equal output, Overbond.spread_to_benchmark
  end

  test 'test_spread_to_benchmark_selects_first_of_two_government_bonds_with_same_term' do
    same_term = '12'
    @overbond = Overbond.new( [
      {bond: 'C1', type: :corporate, term: 10.3, yield: 5.30},
      {bond: 'G1', type: :government, term: same_term, yield: 4.80},
      {bond: 'G2', type: :government, term: same_term, yield: 3.70},
    ])

    assert_match 'C1,G1,0.50', overbond.spread_to_benchmark
  end
  
  

  test 'test_spread_to_curve_calculates_expected_values_from_sample_input' do
    output = <<-CSV.gsub(' ', '')
      bond,spread_to_curve
      C1,1.43
      C2,1.63
      C3,2.47
      C4,2.27
      C5,1.90
      C6,1.57
      C7,2.83
    CSV

    assert_equal output, overbond.spread_to_curve
  end


end
