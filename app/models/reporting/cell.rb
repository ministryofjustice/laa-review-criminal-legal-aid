module Reporting
  class Cell
    def initialize(content, header: false)
      @content = content
      @header = header
    end

    attr_reader :header, :content

    def to_partial_path
      if header
        'reporting/header_cell'
      else
        'reporting/cell'
      end
    end
  end
end
