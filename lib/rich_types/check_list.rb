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
          for i in @opt_list.keys
            @opt_list[i][:checked] = what.include?(i)
          end

      elsif klass == String
        # Convert to Array and use = for Arrays
        self.options = what.split(',').inject(Array.new){|r, c| r.push c.to_i}

      elsif klass == NilClass
        for i in @opt_list.keys
          @opt_list[i][:checked] = false
        end
      end
    end

    def to_s
      result = ""
      for i in @opt_list.keys
        result += i.to_s + "," if @opt_list[i][:checked]
      end
      result.chop
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
