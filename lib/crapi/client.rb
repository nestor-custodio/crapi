require 'active_support/all'
require 'net/http'
require 'openssl'

require 'crapi/proxy'
require 'crapi/errors'

module Crapi
  # Provides a connection mechanism, simple CRUD methods ({#delete} / {#get} / {#patch} / {#post} /
  # {#put}), and proxy generators.
  #
  class Client
    # A Hash containing headers to send with every request (unless overriden elsewhere). Headers
    # set by the user via the CRUD methods' *headers* still override any conflicting default
    # header.
    #
    attr_accessor :default_headers

    # The content-type for JSON data.
    #
    JSON_CONTENT_TYPE = 'application/json'.freeze

    # The content-type for FORM data.
    #
    FORM_CONTENT_TYPE = 'application/x-www-form-urlencoded'.freeze

    # @param base_uri [URI, String]
    #   The base URI the client should use for determining the host to connect to, determining
    #   whether SSH is applicable, and setting the base path for subsequent CRUD calls.
    #
    # @param opts [Hash]
    #   Method options. All method options are **optional** in this particular case.
    #
    # @option opts [true, false] :insecure
    #   Whether to allow insecure SSH connections (i.e. don't attempt to verify the validity of the
    #   given certificate).
    #
    # @option opts [String] :proxy_host
    #   The DNS name or IP address of a proxy server to use when connecting to the target system.
    #   Maps to `Net::HTTP#new`'s *p_addr*.
    #
    # @option opts [Number] :proxy_port
    #   The proxy server port to use when connecting to the target system.
    #   Maps to `Net::HTTP#new`'s *p_port*.
    #
    # @option opts [String] :proxy_username
    #   The username to give if authorization is required to access the specified proxy host.
    #   Maps to `Net::HTTP#new`'s *p_user*.
    #
    # @option opts [Number] :proxy_password
    #   The password to give if authorization is required to access the specified proxy host.
    #   Maps to `Net::HTTP#new`'s *p_pass*.
    #
    #
    # @raise [Crapi::ArgumentError]
    #
    def initialize(base_uri, opts = {})
      @base_uri = case base_uri
                  when URI then base_uri
                  when String then URI(base_uri)
                  else raise Crapi::ArgumentError, %(Unexpected "base_uri" type: #{base_uri.class})
                  end

      @proxy_host = opts[:proxy_host]
      @proxy_port = opts[:proxy_port]
      @proxy_username = opts[:proxy_username]
      @proxy_password = opts[:proxy_password]

      @http = Net::HTTP.new(@base_uri.host, @base_uri.port,
                            @proxy_host, @proxy_port, @proxy_username, @proxy_password)
      @http.use_ssl = (@base_uri.scheme == 'https')
      @http.verify_mode = ::OpenSSL::SSL::VERIFY_NONE if opts[:insecure].present?

      @default_headers = { 'Content-Type': JSON_CONTENT_TYPE }.with_indifferent_access
    end

    # Returns a new {Crapi::Proxy Crapi::Proxy} for this client.
    #
    #
    # @param segment [String]
    #   The segment to add to this client's path.
    #
    # @param headers [Hash]
    #   The default headers for the new proxy.
    #
    #
    # @return [Crapi::Proxy]
    #
    def new_proxy(segment = '/', headers: nil)
      Proxy.new(add: segment, to: self, headers: headers)
    end

    # CRUD methods ...

    # CRUD method: DELETE
    #
    # @param path [String]
    #   The path to the resource to DELETE. Note that this path is always interpreted as relative
    #   to the client's base_uri's path, regardless of whether it begins with a "/".
    #
    # @param headers [Hash]
    #   Additional headers to set in addition to the client's defaults. Any header given here and
    #   also appearing in the client's defaults will override said default value.
    #
    # @param query [Hash, Array, String]
    #   Query string values, if any, to append to the given path. Strings are appended as-is;
    #   Hashes and Arrays are serialized as URI-encoded form data before appending.
    #
    #
    # @return [Object]
    #
    def delete(path, headers: {}, query: {})
      headers = @default_headers.merge(headers)

      response = @http.delete(full_path(path, query: query), headers)
      ensure_success!(response)
      parse_response(response)
    end

    # CRUD method: GET
    #
    # @param path [String]
    #   The path to the resource to GET. Note that this path is always interpreted as relative to
    #   the client's base_uri's path, regardless of whether it begins with a "/".
    #
    # @param headers [Hash]
    #   Additional headers to set in addition to the client's defaults. Any header given here and
    #   also appearing in the client's defaults will override said default value.
    #
    # @param query [Hash, Array, String]
    #   Query string values, if any, to append to the given path. Strings are appended as-is;
    #   Hashes and Arrays are serialized as URI-encoded form data before appending.
    #
    #
    # @return [Object]
    #
    def get(path, headers: {}, query: {})
      headers = @default_headers.merge(headers)

      response = @http.get(full_path(path, query: query), headers)
      ensure_success!(response)
      parse_response(response)
    end

    # CRUD method: PATCH
    #
    # @param path [String]
    #   The path to the resource to PATCH. Note that this path is always interpreted as relative to
    #   the client's base_uri's path, regardless of whether it begins with a "/".
    #
    # @param headers [Hash]
    #   Additional headers to set in addition to the client's defaults. Any header given here and
    #   also appearing in the client's defaults will override said default value.
    #
    # @param query [Hash, Array, String]
    #   Query string values, if any, to append to the given path. Strings are appended as-is;
    #   Hashes and Arrays are serialized as URI-encoded form data before appending.
    #
    # @param payload [Hash, String]
    #   The payload to send, if any. Strings are used as-is; Hashes are serialized per the
    #   request's "Content-Type" header.
    #
    #
    # @return [Object]
    #
    def patch(path, headers: {}, query: {}, payload: {})
      headers = @default_headers.merge(headers)
      payload = format_payload(payload, as: headers[:'Content-Type'])

      response = @http.patch(full_path(path, query: query), payload, headers)
      ensure_success!(response)
      parse_response(response)
    end

    # CRUD method: POST
    #
    # @param path [String]
    #   The path to the resource to POST. Note that this path is always interpreted as relative to
    #   the client's base_uri's path, regardless of whether it begins with a "/".
    #
    # @param headers [Hash]
    #   Additional headers to set in addition to the client's defaults. Any header given here and
    #   also appearing in the client's defaults will override said default value.
    #
    # @param query [Hash, Array, String]
    #   Query string values, if any, to append to the given path. Strings are appended as-is;
    #   Hashes and Arrays are serialized as URI-encoded form data before appending.
    #
    # @param payload [Hash, String]
    #   The payload to send, if any. Strings are used as-is; Hashes are serialized per the
    #   request's "Content-Type" header.
    #
    #
    # @return [Object]
    #
    def post(path, headers: {}, query: {}, payload: {})
      headers = @default_headers.merge(headers)
      payload = format_payload(payload, as: headers[:'Content-Type'])

      response = @http.post(full_path(path, query: query), payload, headers)
      ensure_success!(response)
      parse_response(response)
    end

    # CRUD method: PUT
    #
    # @param path [String]
    #   The path to the resource to PATCH. Note that this path is always interpreted as relative to
    #   the client's base_uri's path, regardless of whether it begins with a "/".
    #
    # @param headers [Hash]
    #   Additional headers to set in addition to the client's defaults. Any header given here and
    #   also appearing in the client's defaults will override said default value.
    #
    # @param query [Hash, Array, String]
    #   Query string values, if any, to append to the given path. Strings are appended as-is;
    #   Hashes and Arrays are serialized as URI-encoded form data before appending.
    #
    # @param payload [Hash, String]
    #   The payload to send, if any. Strings are used as-is; Hashes are serialized per the
    #   request's "Content-Type" header.
    #
    #
    # @return [Object]
    #
    def put(path, headers: {}, query: {}, payload: {})
      headers = @default_headers.merge(headers)
      payload = format_payload(payload, as: headers[:'Content-Type'])

      response = @http.put(full_path(path, query: query), payload, headers)
      ensure_success!(response)
      parse_response(response)
    end

    private

    # Assembles a path and a query string Hash/Array/String into a URI path.
    #
    #
    # @param path [String]
    #   The path to the desired resource.
    #
    # @param query [Hash, Array, String]
    #   Query string values, if any, to append to the given path. Strings are appended as-is;
    #   Hashes and Arrays are serialized as URI-encoded form data before appending.
    #
    #
    # @raise [Crapi::ArgumentError]
    #
    # @return [String]
    #
    def full_path(path, query: {})
      path = [@base_uri.path, path].map { |i| i.gsub(%r{^/|/$}, '') }.keep_if(&:present?)
      path = "/#{path.join('/')}"

      if query.present?
        path += case query
                when Hash, Array then "?#{URI.encode_www_form(query)}"
                when String then "?#{query}"
                else raise Crapi::ArgumentError, %(Unexpected "query" type: #{query.class})
                end
      end

      path
    end

    # Verifies the given value is that of a successful HTTP response.
    #
    #
    # @param response [Net::HTTPResponse]
    #   The response to evaluate as "successful" or not.
    #
    #
    # @raise [Crapi::BadHttpResponseError]
    #
    # @return [nil]
    #
    def ensure_success!(response)
      return if response.is_a? Net::HTTPSuccess

      message = "#{response.code} - #{response.message}"
      message += "\n#{response.body}" if response.body.present?

      raise Crapi::BadHttpResponseError, message
    end

    # Serializes the given payload per the requested content-type.
    #
    #
    # @param payload [Hash, String]
    #   The payload to format. Strings are returned as-is; Hashes are serialized per the given *as*
    #   content-type.
    #
    # @param as [String]
    #   The target content-type.
    #
    #
    # @return [String]
    #
    def format_payload(payload, as: JSON_CONTENT_TYPE)
      # Non-Hash payloads are passed through as-is.
      return payload unless payload.is_a? Hash

      # Massage Hash-like payloads into a suitable format.
      case as
      when JSON_CONTENT_TYPE
        JSON.generate(payload.as_json)
      when FORM_CONTENT_TYPE
        payload.to_query
      else
        payload.to_s
      end
    end

    # Parses the given response as its claimed content-type.
    #
    #
    # @param response [Net::HTTPResponse]
    #   The response whose body is to be parsed.
    #
    #
    # @return [Object]
    #
    def parse_response(response)
      case response.content_type
      when JSON_CONTENT_TYPE
        JSON.parse(response.body, quirks_mode: true, symbolize_names: true)
      else
        response.body
      end
    end
  end

  # Net::HTTP needs a shortcut instance method for PUT calls like it does for GET/DELETE/PATCH/POST.
  #
  class Net::HTTP
    # Convenience PUT method monkey-patched into Net::HTTP.
    #
    # Net::HTTP provides handy methods for DELETE, GET, HEAD, OPTIONS, PATCH, and POST, **but not
    # PUT**, so we have to monkey-patch one in. The parameters listed below were chosen to match
    # those in use for the other Net::HTTP request methods in both name and meaning.
    #
    #
    # @param path [String]
    # @param data [String]
    # @param initheader [Hash]
    # @param dest [nil]
    #
    #
    # @return [Net::HTTPResponse]
    #
    # @see https://docs.ruby-lang.org/en/trunk/Net/HTTP.html
    def put(path, data, initheader = nil, dest = nil, &block)
      send_entity(path, data, initheader, dest, Put, &block)
    end
  end
end
