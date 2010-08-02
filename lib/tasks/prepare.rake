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
      raw_data      = Net::HTTP.get_response(URI.parse(uri)).body
      project_data  = REXML::Document.new(raw_data)
      projects_el   = project_data.children

      removed_sth   = true    # So it'll enter loop first time
      while removed_sth       # Repeat until there is nothing left to remove
        removed_sth = false
        projects_el = projects_el.collect do |x|      # Check all elements
          if x.respond_to?(:name) && x.name == name   # If element has name and
                                                      # it's what we're looking
                                                      # for let it stay.
            x
          else
            removed_sth =  true                       # otherwise remove it
            x.respond_to?(:children) ? x.children : nil
          end
        end

        # Remove nils & flatten array
        if removed_sth
          projects_el.flatten!
          projects_el.compact!
        end
      end
      projects_el
    end

    devs      = []
    projects  = get_all_tags_with_name('http://www.gentoo.org/proj/en/metastructure/gentoo.xml?passthru=1', 'subproject')

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
