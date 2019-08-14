# app.rb
require 'bundler'
require 'sinatra'
require 'sinatra/activerecord'
require 'restforce'
require 'salesforce_bulk_api'
require 'will_paginate'
require 'faker'
Bundler.require

# We need to load the PG database that we are going to use
set :database, ENV['DATABASE_URL']

#Setup RestForce for easy SFDC API access
salesforce_rest = Restforce.new
#Setup RestForce Bulk Extensions, and throttle the connection
salesforce_bulk = Restforce.new
salesforce_bulk.connection.set_status_throttle(30)

class App < Sinatra::Base
  include Sinatra::ActiveRecordExtension
  
  #Let's load all of the models we are going to use to access tables in the DB
  Dir["./models/*.rb"].each {|file| require file }
  
  #Pull in the Helpers file with additonal code
  helpers do
    require_relative 'helpers'
  end
  
  get "/" do
    @total_records = record_counter()
    @new_records = new_records_counter()
    
    erb :index, :layout => :theme
  end
  
  get "/loader" do
    @new_records = new_records()
    @results = record_sender("target_object__b", @new_records)

    erb :loader, :layout => :theme
  end
end