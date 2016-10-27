

desc 'run the shits'
task :run => :'runner:env' do
  Runner.run
end

desc 'look the shits'
task :monitor => :'runner:env' do
  File.write("/var/run/tempmon.pid", Process.pid) rescue nil
  Poller.go
end

task :console => :'runner:env' do
  require 'pry'
  binding.pry
end

namespace :runner do
  task :env do
    #require_relative 'setup'
    #Setup.rake
    %w|poller.rb procline.rb runner.rb settings.rb temp_manager.rb
       temp_controller.rb change_notifier.rb button_monitor.rb state_manager.rb
       temperature_neighborhood.rb|.each do |f|
      require_relative "./#{f}"
    end
  end
end

