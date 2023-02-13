module Reporting
  class Table
    def initialize(table_hash)
      @table_hash = table_hash
    end

    def headers
      @headers ||= table_hash.keys.map do |header|
        I18n.t(header, scope: :table_headings)
      end
    end

    def rows
      @rows ||= table_hash.values.transpose
    end

    private

    attr_reader :table_hash
  end
end
