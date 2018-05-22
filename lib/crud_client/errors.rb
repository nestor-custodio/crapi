module CrudClient
  class Error < ::StandardError
  end

  class ArgumentError < Error
  end

  class BadHttpResponseError < Error
  end
end
