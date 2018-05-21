class CrudClient
  class Error < ::StandardError
  end

  class ParameterError < Error
  end

  class UnexpectedContentType < Error
  end
end
