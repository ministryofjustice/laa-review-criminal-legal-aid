module Reporting
  class Cell
    def initialize(content, header: false, numeric: true)
      @content = content
      @header = header
      @numeric = numeric
    end

    attr_reader :header, :content, :numeric
  end
end
