require "ftools"

desc "Prepare database and configuration files to run tests (accepts options used by prepare:config and seed option)"
opt = ENV.include?('seed') ? ['db:seed'] : []
task :prepare => ['prepare:config', 'db:schema:load'] + opt

namespace :prepare do

  desc "Prepare configuration files (you can pass db=[none|sqlite3|postgres])"
  task :config do

    if !ENV.include?('db') || (ENV['db'] == 'none')
      # don't change anything

    elsif ENV['db'] == 'sqlite3'
      File.copy('doc/config/database-sqlite3.yml', 'config/database.yml')

    elsif ENV['db'] == 'postgres'
      File.copy('doc/config/database-postgres.yml', 'config/database.yml')
      puts "Now you have a template postgeres configuration in config/database.yml.
            Remember to set user and database names matching you configuration."

    else
      raise "valid values for db are sqlite3, postgres, none"
    end

    File.copy('doc/config/config.yml', 'config/config.yml')
  end
end
