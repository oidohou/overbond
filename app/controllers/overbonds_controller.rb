class OverbondsController < ApplicationController

    before_action :corporate_bonds
    before_action :government_bonds

    def import 
        Overbonds.import(params[:file])
    end

    def spread_to_curve
        spread_to_curve(params[:corporate_bonds])
        
    end

    private
    def corporate_bonds 
        @corporate_bonds =  Overbond.where(type: "corporate")
    end
    def government_bonds
        @government_bonds  = Overbond.where(type: "government")
    end
end