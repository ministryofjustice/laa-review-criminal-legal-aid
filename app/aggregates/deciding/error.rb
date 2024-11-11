module Deciding
  class Error < StandardError
    def message_key
      self.class.name.demodulize.underscore.to_sym
    end
  end
end
