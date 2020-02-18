require 'test_helper'

class OverbondTest < ActiveSupport::TestCase
  def test_requires_bonds
    error = assert_raises ArgumentError do
      Overbond.new
    end

    assert_equal 'missing keyword: bonds', error.message
  end

  def test_extracts_the_corporate_bonds
    corporate_bonds = overbond.corporate_bonds

    refute_empty corporate_bonds
    corporate_bonds.each do |bond|
      assert_instance_of Bond, bond
      assert_equal :corporate, bond.type
    end
  end

  def test_extracts_the_government_bonds
    government_bonds = overbond.government_bonds

    refute_empty government_bonds
    government_bonds.each do |bond|
      assert_instance_of Bond, bond
      assert_equal :government, bond.type
    end
  end

  def test_spread_to_benchmark_confirms_sample_output_results
    @bonds_file_path = 'data/spread_to_benchmark_sample.csv'
    expected_output = <<-CSV.gsub(' ', '')
      bond,benchmark,spread_to_benchmark
      C1,G1,1.60%
    CSV

    assert_equal expected_output, overbond.spread_to_benchmark
  end

  def test_spread_to_curve_for_corporate_bond_term_equal_to_government_bond_term
    same_term = '12 years'
    @overbond = Overbond.new(bonds: [
      Bond.new(id: 'C1', type: :corporate, term: same_term, yield_spread: '5.30%'),
      Bond.new(id: 'G1', type: :government, term: '10.3 years', yield_spread: '4.80%'),
      Bond.new(id: 'G2', type: :government, term: same_term, yield_spread: '5.70%'),
      Bond.new(id: 'G3', type: :government, term: '15.7 years', yield_spread: '6.90%'),
    ])

    assert_match 'C1,0.40%', overbond.spread_to_curve
  end

  

  def test_spread_to_benchmark_calculates_expected_values_from_sample_input
    output = <<-CSV.gsub(' ', '')
      bond,benchmark,spread_to_benchmark
      C1,G1,1.60%
      C2,G2,1.50%
      C3,G3,2.00%
      C4,G3,2.90%
      C5,G4,0.90%
      C6,G5,1.80%
      C7,G6,2.50%
    CSV

    assert_equal output, overbond.spread_to_benchmark
  end

  def test_spread_to_benchmark_selects_first_of_two_government_bonds_with_same_term
    same_term = '12 years'
    @overbond = Overbond.new(bonds: [
      Bond.new(id: 'C1', type: :corporate, term: '10.3 years', yield_spread: '5.30%'),
      Bond.new(id: 'G1', type: :government, term: same_term, yield_spread: '4.80%'),
      Bond.new(id: 'G2', type: :government, term: same_term, yield_spread: '3.70%'),
    ])

    assert_match 'C1,G1,0.50%', overbond.spread_to_benchmark
  end
  
  def test_spread_to_curve_confirms_sample_output_results
    @bonds_file_path = 'data/spread_to_curve_sample.csv'
    expected_output = <<-CSV.gsub(' ', '')
      bond,spread_to_curve
      C1,1.22%
      C2,2.98%
    CSV

    assert_equal expected_output, overbond.spread_to_curve
  end

  def test_spread_to_curve_calculates_expected_values_from_sample_input
    output = <<-CSV.gsub(' ', '')
      bond,spread_to_curve
      C1,1.43%
      C2,1.63%
      C3,2.47%
      C4,2.27%
      C5,1.90%
      C6,1.57%
      C7,2.83%
    CSV

    assert_equal output, overbond.spread_to_curve
  end

 

  private

  def overbond
    @overbond ||= Overbond.new(bonds: bonds)
  end

  def bonds
    @bonds ||= BondParser.new(file_path: bonds_file_path).parse
  end

  def bonds_file_path
    @bonds_file_path ||= 'data/sample_input.csv'
  end
end
