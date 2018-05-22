require 'active_support/all'

require 'crud_client/errors'
require 'http/message'

class CrudClient::Client
  def initialize(base_url: nil, custom_client: nil)
    @http = case custom_client
            when HTTPClient
              custom_client
            when nil
              raise ParameterError, 'No `base_url` given.' if base_url.blank?
              HTTPClient.new(base_url: base_url)
            else
              raise ParameterError, 'Invalid `custom_client` parameter.'
            end

    @http.default_header['Accept'] = 'application/json'
    @http.default_header['Content-Type'] = 'application/json'
  end

  ## Proxies for HTTP methods ...

  def head(*args, &block)
    @http.head(*args, &block)
  end

  def options(*args, &block)
    @http.options(*args, &block)
  end

  def get(*args, &block)
    @http.get(*args, &block).parse_as_json
  end

  def post(*args, &block)
    @http.post(*args, &block).parse_as_json
  end

  def put(*args, &block)
    @http.put(*args, &block).parse_as_json
  end

  def patch(*args, &block)
    @http.patch(*args, &block).parse_as_json
  end
end
