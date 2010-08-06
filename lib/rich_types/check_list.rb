module RichTypes
  # Stores information on which options were selected.
  # Use options and options= methods to access & set information on which are selected.
  # Options are set on object creation time.
  class CheckList
    # initialize options list
    def initialize(options)
      @opt_list = CheckList.get_opts(options)
    end

    # return hash.
    # result[option.id] = {:checked => Boolean, :content => String, :id => Integer}
    def options
      @opt_list
    end

    # Accepts Arrays (containing id's of checked options),
    # Hashes (indexed with option.ids, each item is hash with Boolean :checked, String :content, Integer :id))
    # and Strings (coma-separated list of id's of checked options)
    # does *NOT* validate.
    def options=(what)
      klass = what.class

      if klass == Hash
        @opt_list = what

      elsif klass == Array
        what = what.collect{ |x| x.to_i }
        for i in @opt_list.keys
          @opt_list[i][:checked] = what.include?(i)
        end

      elsif klass == String
        # Convert to Array and use = for Arrays
        self.options = YAML::load(what)

      elsif klass == NilClass
        for i in @opt_list.keys
          @opt_list[i][:checked] = false
        end
      end
    end

    def to_s
      selected = @opt_list.collect{ |x| x[0] if x[1][:checked] }
      selected = selected.flatten.uniq.compact.sort
      selected.to_yaml.strip
    end

    protected
      def self.get_opts(options)
        options.inject(Hash.new) do |result, opt|
          result[opt.id] = {:checked => false, :content => opt.content, :id => opt.id}
          result
        end
      end
  end
end
