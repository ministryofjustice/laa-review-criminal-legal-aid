module Deciding
  class Error < StandardError
    # :nocov:
    def message_key
      self.class.name.demodulize.underscore.to_sym
    end
    # :nocov:
  end
end
