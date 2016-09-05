require 'liebre'

task :environment

namespace :liebre do
  
  desc "Starts Liebre:Runner"
  task :run => :environment do
    Liebre::Runner.start
  end
  
end