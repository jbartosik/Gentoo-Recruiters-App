begin
  if Rails.env.test? || Rails.env.cucumber?
    # Tests must be run in known environment
    APP_CONFIG = { 'developer_data' => { 'check' => false },
                    'notifications' => { 'new_user' => 'example@example.com' } }
  else
    APP_CONFIG = YAML.load_file("#{RAILS_ROOT}/config/config.yml")[RAILS_ENV]
  end
rescue
  APP_CONFIG = Hash.new
end

class ConfigChecker
  def initialize(config = Hash.new, key_prefix = '')
    @errors = []
    self.config = config
    self.key_prefix = key_prefix
  end

  def config=(new_conf)
    @config = new_conf || Hash.new
  end

  def key_prefix=(new_prefix)
    @key_prefix = new_prefix || String.new
  end

  def errors
    @errors
  end

  def config_must_have(key, type = Object)
    @errors.push "Not found required key '#{@key_prefix}#{key}' in configuration." and return unless @config.include?(key)
    @errors.push "Key '#{@key_prefix}#{key}' found in configuration but has wrong type (expected #{type})." unless @config[key].is_a? type
  end

  def config_must_have_one_of(keys, type = Object)
    keys_s  = keys.inject(nil) do |res, cur|
      if res.nil?
       "'#{@key_prefix}#{cur}'"
      else
       "#{res}, '#{@key_prefix}#{cur}'"
      end
    end

    found         = keys.inject(false) { |res, cur| res |= @config.include?(cur) }
    correct_type  = keys.inject(false) { |res, cur| res |= @config.include?(cur) && @config[cur].is_a?(type) }

    @errors.push "You should provide at least one of those keys: #{keys_s} in configuration." and return unless found
    @errors.push "All of those keys: #{keys_s} were not present or had wrong (expected #{type})." unless correct_type
  end
end

checker         = ConfigChecker.new(APP_CONFIG)

checker.config_must_have('developer_data',  Hash)

checker.config      = APP_CONFIG['developer_data']
checker.key_prefix  = 'developer_data/'

checker.config_must_have('check')

if APP_CONFIG['developer_data'].try['check']
  checker.config_must_have('min_months_mentor_is_dev')
  checker.config_must_have_one_of(['uri', 'data'])
end

checker = ConfigChecker.new(APP_CONFIG)
checker.config_must_have('notifications',  Hash)
checker.config = APP_CONFIG['notifications']
checker.key_prefix  = 'notifications/'
checker.config_must_have('new_user',  String)

unless checker.errors.empty?
  puts "Error(s) while checking configuration:"
  checker.errors.each{ |err| puts " * #{err}" }
  exit
end
