module Deciding
  class Error < StandardError
    # simplecov:disable
    def message_key
      self.class.name.demodulize.underscore.to_sym
    end
    # simplecov:enable
  end
end
