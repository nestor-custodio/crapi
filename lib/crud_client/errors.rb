module CrudClient
  class Error < ::StandardError
  end

  class ParameterError < Error
  end

  class BadHttpResponseError < Error
  end
end
