# README

This README would normally document whatever steps are necessary to get the
application up and running.

* Database creation

    Database used : pg
    
    * $rails db:create
    
    * $rails db:migrate

* Database initialization

    In the rails console 
    
        Overbond.import

* How to run the test suite
    
    $rails test

* Spread to curve and Spread to benchmark

    In the rails console  =  $rails c

    Initialize global attributes

        * overbond = Overbond.initializeGov

        * overbond = Overbond.initializeCorp

    Spreads

        overbond.spread_to_curve

        overbond.spread_to_benchmark

