# This must not be automagically included.
# If this is included automatically Mail gem will not load properly and
# things will break.
module Mail
  class Message
    def signatures
      boundary = content_type._?.match(/boundary="?([^;"]*)"?;?/)._?.captures._?.first
      return [] unless boundary

      boundary = Regexp.escape(boundary)
      signed = body.decoded.match(/#{boundary}\n(.*?)\n\-*#{boundary}/m)._?.captures._?.first
      return [] unless signed

      result = []
      for part in parts[1..-1]
        begin
          GPGME::verify(part.decoded, signed){ |signature| result.push signature.to_s}
        rescue
          # Some signatures break GPGME::Signature#to_s - report them
          result = []
          GPGME::verify(part.decoded, signed) do |signature|
            result.push "Breaking signature"
          end
        end
      end
      result
    end
  end
end
