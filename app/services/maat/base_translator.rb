module Maat
  class BaseTranslator
    def initialize(original:)
      @original = original
    end

    class << self
      def translate(original)
        new(original:).translate
      end
    end

    # :nocov:
    def translate
      raise 'implement in subclasses'
    end
    # :nocov:
    #

    private

    attr_reader :original
  end
end
