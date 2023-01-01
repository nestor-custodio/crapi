module CrAPI
  # The base Error class for all {CrAPI}-related issues.
  #
  class Error < ::StandardError
  end

  # An error relating to missing, invalid, or incompatible method arguments.
  #
  class ArgumentError < Error
  end

  # An error relating to a 4XX/5XX HTTP response code.
  #
  class BadHttpResponseError < Error
  end
end
