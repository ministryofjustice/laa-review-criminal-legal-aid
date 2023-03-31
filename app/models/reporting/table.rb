module Reporting
  class Table
    # Table view object for presenting reports
    # @param table_hash [Hash<Symbol, Array(String, Fixnum)>] table
    #  column data keyed by column name
    # @param numeric_column_keys [Array(Symbol)] numeric_column_keys,
    #   if nil it assumes all but the first column are numeric.
    def initialize(table_hash, numeric_column_keys: nil)
      @table_hash = table_hash
      @numeric_column_keys = numeric_column_keys || default_numeric_column_keys
    end

    def headers
      @headers ||= table_hash.keys.map do |header|
        Cell.new(
          I18n.t(header, scope: :table_headings),
          header: true,
          numeric: numeric_column?(header)
        )
      end
    end

    def rows
      @rows ||= table_hash.values.transpose
    end

    private

    attr_reader :table_hash, :numeric_column_keys

    def numeric_column?(key)
      numeric_column_keys.include?(key)
    end

    # All bar the first column are assumed to be numeric
    def default_numeric_column_keys
      numeric_keys = table_hash.keys.dup
      numeric_keys.shift
      numeric_keys
    end
  end
end
