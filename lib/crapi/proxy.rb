require 'active_support/all'

module Crapi
  ## Proxies simple CRUD methods ({#delete} / {#get} / {#patch} / {#post} / {#put}) for a
  ## {Crapi::Client Crapi::Client} or another {Crapi::Proxy Crapi::Proxy}. Like
  ## {Crapi::Client Crapi::Client}, it also provides a proxy generator.
  ##
  ## A {Crapi::Proxy Crapi::Proxy} has its own set of default headers and has a segment that is
  ## prepended to its CRUD methods' *path* before being passed to the parent
  ## {Crapi::Client Crapi::Client}/{Crapi::Proxy Crapi::Proxy}. This makes the proxxy functionally
  ## equivalent to a new {Crapi::Client Crapi::Client} with a new base path (the parent's base path
  ## plus the proxy's segment) and more default headers, but without the need for a separate
  ## connection to the target system.
  ##
  class Proxy
    ## A Hash containing headers to send with every request (unless overriden elsewhere). In case of
    ## conflicts, headers set as default for a {Crapi::Proxy Crapi::Proxy} override those set by the
    ## parent. As in a {Crapi::Client Crapi::Client}, headers set by the user via the CRUD methods'
    ## *headers* still override any conflicting default header.
    ##
    ##
    ## @see Crapi::Client#default_headers Crapi::Client#default_headers
    ##
    attr_accessor :default_headers

    ## @param add [String]
    ##   The new base path. This path (added to the parent's base path) will be used as the base
    ##   path for the {Crapi::Proxy Crapi::Proxy}'s CRUD methods.
    ##
    ## @param to [Crapi::Client, Crapi::Proxy]
    ##   The parent {Crapi::Client Crapi::Client} or {Crapi::Proxy Crapi::Proxy} that we'll be
    ##   delegating CRUD calls to after proprocessing of headers and paths.
    ##
    ## @param headers [Hash]
    ##   The default headers to send with every request (unless overriden elsewhere).
    ##
    def initialize(add:, to:, headers: nil)
      @parent = to
      @segment = add
      @default_headers = (headers || {}).with_indifferent_access
    end

    ## Returns a new {Crapi::Proxy Crapi::Proxy} for this proxy.
    ##
    ##
    ## @param segment [String]
    ##   The segment to add to this proxy's path.
    ##
    ## @param headers [Hash]
    ##   The default headers for the new proxy.
    ##
    ##
    ## @return [Crapi::Proxy]
    ##
    ## @see Crapi::Client#new_proxy Crapi::Client#new_proxy
    ##
    def new_proxy(segment = '/', headers: nil)
      Proxy.new(add: segment, to: self, headers: headers)
    end

    ## CRUD methods ...

    ## CRUD method: DELETE
    ##
    ##
    ## @return [Object]
    ##
    ## @see Crapi::Client#delete Crapi::Client#delete
    ##
    def delete(path, headers: {}, query: {})
      @parent.delete("/#{@segment}/#{path}".gsub(%r{/+}, '/'),
                     headers: @default_headers.merge(headers), query: query)
    end

    ## CRUD method: GET
    ##
    ##
    ## @return [Object]
    ##
    ## @see Crapi::Client#get Crapi::Client#get
    ##
    def get(path, headers: {}, query: {})
      @parent.get("/#{@segment}/#{path}".gsub(%r{/+}, '/'),
                  headers: @default_headers.merge(headers), query: query)
    end

    ## CRUD method: PATCH
    ##
    ##
    ## @return [Object]
    ##
    ## @see Crapi::Client#patch Crapi::Client#patch
    ##
    def patch(path, headers: {}, query: {}, payload: {})
      @parent.patch("/#{@segment}/#{path}".gsub(%r{/+}, '/'),
                    heades: @default_headers.merge(headers), query: query, payload: payload)
    end

    ## CRUD method: POST
    ##
    ##
    ## @return [Object]
    ##
    ## @see Crapi::Client#post Crapi::Client#post
    ##
    def post(path, headers: {}, query: {}, payload: {})
      @parent.post("/#{@segment}/#{path}".gsub(%r{/+}, '/'),
                   headers: @default_headers.merge(headers), query: query, payload: payload)
    end

    ## CRUD method: PUT
    ##
    ##
    ## @return [Object]
    ##
    ## @see Crapi::Client#put Crapi::Client#put
    ##
    def put(path, headers: {}, query: {}, payload: {})
      @parent.put("/#{@segment}/#{path}".gsub(%r{/+}, '/'),
                  headers: @default_headers.merge(headers), query: query, payload: payload)
    end
  end
end
