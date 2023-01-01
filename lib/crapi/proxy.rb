require 'active_support/all'

module CrAPI
  # Proxies simple CRUD methods ({#delete} / {#get} / {#patch} / {#post} / {#put}) for a
  # {CrAPI::Client CrAPI::Client} or another {CrAPI::Proxy CrAPI::Proxy}. Like
  # {CrAPI::Client CrAPI::Client}, it also provides a proxy generator.
  #
  # A {CrAPI::Proxy CrAPI::Proxy} has its own set of default headers and has a segment that is
  # prepended to its CRUD methods' *path* before being passed to the parent
  # {CrAPI::Client CrAPI::Client}/{CrAPI::Proxy CrAPI::Proxy}. This makes the proxxy functionally
  # equivalent to a new {CrAPI::Client CrAPI::Client} with a new base path (the parent's base path
  # plus the proxy's segment) and more default headers, but without the need for a separate
  # connection to the target system.
  #
  class Proxy
    # A Hash containing headers to send with every request (unless overriden elsewhere). In case of
    # conflicts, headers set as default for a {CrAPI::Proxy CrAPI::Proxy} override those set by the
    # parent. As in a {CrAPI::Client CrAPI::Client}, headers set by the user via the CRUD methods'
    # *headers* still override any conflicting default header.
    #
    #
    # @see CrAPI::Client#default_headers CrAPI::Client#default_headers
    #
    attr_accessor :default_headers

    # @param add [String]
    #   The new base path. This path (added to the parent's base path) will be used as the base
    #   path for the {CrAPI::Proxy CrAPI::Proxy}'s CRUD methods.
    #
    # @param to [CrAPI::Client, CrAPI::Proxy]
    #   The parent {CrAPI::Client CrAPI::Client} or {CrAPI::Proxy CrAPI::Proxy} that we'll be
    #   delegating CRUD calls to after proprocessing of headers and paths.
    #
    # @param headers [Hash]
    #   The default headers to send with every request (unless overriden elsewhere).
    #
    def initialize(add:, to:, headers: nil)
      @parent = to
      @segment = add
      @default_headers = (headers || {}).with_indifferent_access
    end

    # Returns a new {CrAPI::Proxy CrAPI::Proxy} for this proxy.
    #
    #
    # @param segment [String]
    #   The segment to add to this proxy's path.
    #
    # @param headers [Hash]
    #   The default headers for the new proxy.
    #
    #
    # @return [CrAPI::Proxy]
    #
    # @see CrAPI::Client#new_proxy CrAPI::Client#new_proxy
    #
    def new_proxy(segment = '/', headers: nil)
      Proxy.new(add: segment, to: self, headers: headers)
    end

    # CRUD methods ...

    # CRUD method: DELETE
    #
    #
    # @return [Object]
    #
    # @see CrAPI::Client#delete CrAPI::Client#delete
    #
    def delete(path, headers: {}, query: {})
      @parent.delete("/#{@segment}/#{path}".gsub(%r{/+}, '/'),
                     headers: @default_headers.merge(headers), query: query)
    end

    # CRUD method: GET
    #
    #
    # @return [Object]
    #
    # @see CrAPI::Client#get CrAPI::Client#get
    #
    def get(path, headers: {}, query: {})
      @parent.get("/#{@segment}/#{path}".gsub(%r{/+}, '/'),
                  headers: @default_headers.merge(headers), query: query)
    end

    # CRUD method: PATCH
    #
    #
    # @return [Object]
    #
    # @see CrAPI::Client#patch CrAPI::Client#patch
    #
    def patch(path, headers: {}, query: {}, payload: {})
      @parent.patch("/#{@segment}/#{path}".gsub(%r{/+}, '/'),
                    heades: @default_headers.merge(headers), query: query, payload: payload)
    end

    # CRUD method: POST
    #
    #
    # @return [Object]
    #
    # @see CrAPI::Client#post CrAPI::Client#post
    #
    def post(path, headers: {}, query: {}, payload: {})
      @parent.post("/#{@segment}/#{path}".gsub(%r{/+}, '/'),
                   headers: @default_headers.merge(headers), query: query, payload: payload)
    end

    # CRUD method: PUT
    #
    #
    # @return [Object]
    #
    # @see CrAPI::Client#put CrAPI::Client#put
    #
    def put(path, headers: {}, query: {}, payload: {})
      @parent.put("/#{@segment}/#{path}".gsub(%r{/+}, '/'),
                  headers: @default_headers.merge(headers), query: query, payload: payload)
    end
  end
end
