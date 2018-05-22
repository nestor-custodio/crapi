require 'json'

require 'crud_client/errors'

class HTTP::Message
  def verify_success!
    return if status_code == 200

    raise CrudClient::UnableToAuthenticateError,
          %(Got "#{reason_phrase}" while fetching authorization code.)
  end

  def parse_as_json
    raise CrudClient::UnexpectedContentTypeError, %(Cannot parse content of type "#{header['Content-Type']}" as JSON.) unless header['Content-Type'].any? { |header| header.match?(%r{\bapplication/json\b}) }

    JSON.parse(body, quirks_mode: true, symbolize_names: true) rescue nil
  end
end
