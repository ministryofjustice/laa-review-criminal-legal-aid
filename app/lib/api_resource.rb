class ApiResource < Dry::Struct
  class << self
    def all
      @all ||= ApiClient.new.all.map do |json|
        new(extract_from_source(json))
      end
    end

    def find(id)
      all.find { |r| r.id == id }
    end

    # Overide if transformation required
    # :nocov:
    def skip_this_method
      never_reached
    end
    # :nocov:
    #
  end
end
