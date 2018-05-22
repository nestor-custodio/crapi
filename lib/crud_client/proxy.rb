require 'active_support/all'

class CrudClient::Proxy
  attr_accessor :default_headers

  def initialize(add:, to:, headers: nil)
    @parent = to
    @segment = add
    @default_headers = (headers || {}).with_indifferent_access
  end

  def new_proxy(segment = '/', headers: nil)
    CrudClient::Proxy.new(add: segment, to: self, headers: headers)
  end

  ## CRUD methods ...

  def get(path, headers: {}, query: {})
    @parent.get("/#{@segment}/#{path}".gsub(%r{/+}, '/'),
                headers: @default_headers.merge(headers), query: query)
  end

  def delete(path, headers: {}, query: {})
    @parent.delete("/#{@segment}/#{path}".gsub(%r{/+}, '/'),
                   headers: @default_headers.merge(headers), query: query)
  end

  def post(path, headers: {}, query: {}, payload: {})
    @parent.post("/#{@segment}/#{path}".gsub(%r{/+}, '/'),
                 headers: @default_headers.merge(headers), query: query, payload: payload)
  end

  def patch(path, headers: {}, query: {}, payload: {})
    @parent.patch("/#{@segment}/#{path}".gsub(%r{/+}, '/'),
                  heades: @default_headers.merge(headers), query: query, payload: payload)
  end

  def put(path, headers: {}, query: {}, payload: {})
    @parent.put("/#{@segment}/#{path}".gsub(%r{/+}, '/'),
                headers: @default_headers.merge(headers), query: query, payload: payload)
  end
end
