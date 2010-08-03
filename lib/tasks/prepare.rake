require "ftools"
require "rexml/document"

desc "Prepare database and configuration files to run tests (accepts options used by prepare:config and seed option)"
opt = ENV.include?('seed') ? ['db:seed'] : []
task :prepare => ['prepare:config', 'db:schema:load'] + opt

namespace :prepare do

  desc "Prepare configuration files (you can pass db=[none|sqlite3|postgres|mysql])"
  task :config do

    if !ENV.include?('db') || (ENV['db'] == 'none')
      # don't change anything

    elsif ENV['db'] == 'sqlite3'
      File.copy('doc/config/database-sqlite3.yml', 'config/database.yml')

    elsif ENV['db'] == 'postgres'
      File.copy('doc/config/database-postgres.yml', 'config/database.yml')
      puts "Now you have a template postgeres configuration in config/database.yml.
            Remember to set user and database names matching you configuration."

    elsif ENV['db'] == 'mysql'
      File.copy('doc/config/database-mysql.yml', 'config/database.yml')
      puts "Now you have a template mysql configuration in config/database.yml.
            Remember to set user and database names matching you configuration."

    else
      raise "valid values for db are sqlite3, postgres, none"
    end

    File.copy('doc/config/config.yml', 'config/config.yml')
  end

  desc "Prepare project Lead data"
  task :lead_data => :environment do

    # Fetch xml document from uri. Collect all elements with name equal to
    # name parameter and array containing them (and only them).
    def get_all_tags_with_name(uri, name)
      begin
        raw_data      = Net::HTTP.get_response(URI.parse(uri)).body
        project_data  = REXML::Document.new(raw_data)
        REXML::XPath.match(project_data, "//#{name}")
      rescue
        # Warn if there was some error and return empty array.
        # This way problems with one document won't break whole process.
        # Down side is that leads may be marked as non-leads (this
        # wouldn't happen if task crashed when encountering a problem)
        Rails.logger.error "Error when trying to collect <#{name}> tags from #{uri}:"
        Rails.logger.error $!
        []
      end
    end

    devs      = []

    projects = []
    subprojects = get_all_tags_with_name('http://www.gentoo.org/proj/en/metastructure/gentoo.xml?passthru=1', 'subproject')
    until subprojects.empty?
      projects += subprojects

      new_subprojects = subprojects.collect do |proj|
        get_all_tags_with_name("http://www.gentoo.org#{proj.attribute('ref').to_s}?passthru=1", 'subproject')
      end

      subprojects = new_subprojects.flatten
    end

    for proj in projects
      devs += get_all_tags_with_name("http://www.gentoo.org#{proj.attribute('ref').to_s}?passthru=1", 'dev')
    end

    leads = devs.collect{ |x| x if /lead/i.match(x.attribute('role').to_s) }.compact
    lead_nicks = leads.collect{ |x| x.text }

    User.transaction do
      for user in User.all
        user.update_attribute(:project_lead, lead_nicks.include?(user.nick))
      end
    end
  end
end
