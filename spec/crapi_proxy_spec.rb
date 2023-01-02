RSpec.describe CrAPI::Proxy do
  subject do
    client = CrAPI::Client.new API_DOMAIN
    client.default_headers.merge! client: '1'

    client.new_proxy '/proxy_path', headers: { client: '0', proxy: '1' }
  end

  let(:payload_hash) { { string_value: 'abc', numeric_value: 123, a_list: %w[one two three] } }
  let(:payload_json) { JSON.generate payload_hash }

  let(:empty_response_spec) { { status: 204, body: nil } }
  let(:payload_response_spec) { { status: 200, headers: { 'content-type': 'application/json' }, body: payload_json } }

  def stub(method, uri, headers: {})
    stub_request(method, "#{API_DOMAIN}/proxy_path/#{uri.delete_prefix '/'}").with(headers: full_request_headers(headers))
  end

  def full_request_headers(custom_values = {})
    subject.default_headers.merge custom_values
  end

  def crud_header_test(method, with_header:)
    uri = '/resource/1'

    if with_header
      unique_header = { 'X-Test' => SecureRandom.hex }
      stub(method, uri, headers: unique_header).to_return(status: 204)
      expect { subject.send(method, uri, headers: unique_header) }.not_to raise_error
    else
      stub(method, uri).to_return(status: 204)
      expect { subject.send(method, uri) }.not_to raise_error
    end
  end

  def crud_parsing_test(method, with_body:)
    uri = '/resource/1'

    if with_body
      stub(method, uri).to_return(payload_response_spec)
      expect(subject.send(method, uri)).to eq(payload_hash)
    else
      stub(method, uri).to_return(empty_response_spec)
      expect(subject.send(method, uri)).to eq(nil)
    end
  end

  # ---

  describe '#new_proxy' do
    it('is defined') { is_expected.to respond_to :new_proxy }
    it('returns a CrAPI::Proxy') { expect(subject.new_proxy).to be_a(CrAPI::Proxy) }
  end

  # ---

  describe '#delete' do
    let(:method) { :delete }

    describe 'sends correctly' do
      it('w/ headers') { crud_header_test(method, with_header: true) }
      it('w/o headers') { crud_header_test(method, with_header: false) }
    end
  end

  describe '#get' do
    let(:method) { :get }

    describe 'sends correctly' do
      it('w/ headers') { crud_header_test(method, with_header: true) }
      it('w/o headers') { crud_header_test(method, with_header: false) }
    end

    describe 'parses responses' do
      it('w/ response body') { crud_parsing_test(method, with_body: true) }
      it('w/o response body') { crud_parsing_test(method, with_body: false) }
    end
  end

  describe '#patch' do
    let(:method) { :patch }

    describe 'sends correctly' do
      it('w/ headers') { crud_header_test(method, with_header: true) }
      it('w/o headers') { crud_header_test(method, with_header: false) }
    end

    describe 'parses responses' do
      it('w/ response body') { crud_parsing_test(method, with_body: true) }
      it('w/o response body') { crud_parsing_test(method, with_body: false) }
    end
  end

  describe '#post' do
    let(:method) { :post }

    describe 'sends correctly' do
      it('w/ headers') { crud_header_test(method, with_header: true) }
      it('w/o headers') { crud_header_test(method, with_header: false) }
    end

    describe 'parses responses' do
      it('w/ response body') { crud_parsing_test(method, with_body: true) }
      it('w/o response body') { crud_parsing_test(method, with_body: false) }
    end
  end

  describe '#put' do
    let(:method) { :put }

    describe 'sends correctly' do
      it('w/ headers') { crud_header_test(method, with_header: true) }
      it('w/o headers') { crud_header_test(method, with_header: false) }
    end

    describe 'parses responses' do
      it('w/ response body') { crud_parsing_test(method, with_body: true) }
      it('w/o response body') { crud_parsing_test(method, with_body: false) }
    end
  end
end
