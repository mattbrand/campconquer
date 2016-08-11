
# from https://github.com/rack/rack/pull/1003#issuecomment-217692335

module Rack
  module Multipart
    class Parser
      old_tag_multipart = instance_method(:tag_multipart_encoding)

      # Unity puts quotes around the chartype and doesn't allow it to change
      # Rack patched this but will not be backporting the fix to 1.6
      define_method(:tag_multipart_encoding) do |filename, content_type, name, body|
        content_type.gsub!('"utf-8"', 'utf-8') if content_type
        old_tag_multipart.bind(self).(filename, content_type, name, body)
      end
    end
  end
end
