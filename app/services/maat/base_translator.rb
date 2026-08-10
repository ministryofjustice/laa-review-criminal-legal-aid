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

    # simplecov:disable
    def translate
      raise 'implement in subclasses'
    end
    # simplecov:enable

    private

    attr_reader :original
  end
end
