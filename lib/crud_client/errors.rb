module CrudClient
  class Error < ::StandardError
  end

  class ParameterError < Error
  end

  class UnexpectedContentTypeError < Error
  end
end
