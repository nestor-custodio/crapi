require 'active_support/all'
require 'net/http'
require 'openssl'

require 'crud_client/proxy'

class CrudClient::Client
  attr_accessor :default_headers

  JSON_CONTENT_TYPE = 'application/json'.freeze
  FORM_CONTENT_TYPE = 'application/x-www-form-urlencoded'.freeze

  def initialize(base_uri, opts = {})
    @base_uri = case base_uri
                when URI then base_uri
                when String then URI(base_uri)
                else raise CrudClient::ParameterError, %(Unexpected "base_url" type: #{base_url.class})
                end

    @proxy_host = opts[:proxy_host]
    @proxy_port = opts[:proxy_port]
    @proxy_username = opts[:proxy_username]
    @proxy_password = opts[:proxy_password]

    @http = Net::HTTP.new(@base_uri.host, @base_uri.port,
                          @proxy_host, @proxy_port, @proxy_username, @proxy_password)
    @http.use_ssl = (@base_uri.scheme == 'https')
    @http.verify_mode = ::OpenSSL::SSL::VERIFY_NONE if opts[:insecure].present?

    @default_headers = { 'content-type': JSON_CONTENT_TYPE }.with_indifferent_access
  end

  def new_proxy(segment = '/', headers: nil)
    CrudClient::Proxy.new(add: segment, to: self, headers: headers)
  end

  ## CRUD methods ...

  def get(path, headers: {}, query: {})
    headers = @default_headers.merge(headers)

    response = @http.get(full_path(path, query: query), headers)
    ensure_success!(response)
    parse_response(response)
  end

  def delete(path, headers: {}, query: {})
    headers = @default_headers.merge(headers)

    response = @http.delete(full_path(path, query: query), headers)
    ensure_success!(response)
    parse_response(response)
  end

  def post(path, headers: {}, query: {}, payload: {})
    headers = @default_headers.merge(headers)
    payload = format_payload(payload, as: headers[:'content-type'])

    response = @http.post(full_path(path, query: query), payload, headers)
    ensure_success!(response)
    parse_response(response)
  end

  def patch(path, headers: {}, query: {}, payload: {})
    headers = @default_headers.merge(headers)
    payload = format_payload(payload, as: headers[:'content-type'])

    response = @http.patch(full_path(path, query: query), payload, headers)
    ensure_success!(response)
    parse_response(response)
  end

  ##

  private

  ##

  def full_path(path, query: {})
    path = [@base_uri.path, path].map { |i| i.gsub(%r{^/|/$}, '') }.keep_if(&:present?)
    path = "/#{path.join('/')}"

    if query.present?
      path += case query
              when Hash, Array then "?#{URI.encode_www_form(query)}"
              when String then "?#{query}"
              else raise CrudClient::ParameterError, %(Unexpected "query" type: #{query.class})
              end
    end

    path
  end

  def ensure_success!(response)
    return if response.is_a? Net::HTTPSuccess
    raise(CrudClient::BadHttpResponseError, "#{response.code} - #{response.message}")
  end

  def format_payload(payload, as: JSON_CONTENT_TYPE)
    case as
    when JSON_CONTENT_TYPE
      JSON.generate(payload.as_json)
    when FORM_CONTENT_TYPE
      URI.encode_www_form(payload)
    else
      payload.to_s
    end
  end

  def parse_response(response)
    case response.content_type
    when JSON_CONTENT_TYPE
      JSON.parse(response.body, quirks_mode: true, symbolize_names: true)
    else
      response.body
    end
  end
end
