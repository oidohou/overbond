class OverbondsController < ApplicationController


    def import 
        Overbonds.import(params[:file])
    end

end