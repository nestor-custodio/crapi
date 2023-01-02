RSpec.describe CrAPI::Error do
  it 'is defined' do
    expect(defined? CrAPI::Error).not_to be(nil)
  end

  describe 'is subclassed as ...' do
    it 'CrAPI::ArgumentError' do
      expect(defined? CrAPI::ArgumentError).not_to be(nil)
      expect(CrAPI::ArgumentError.superclass).to be(CrAPI::Error)
    end

    it 'CrAPI::BadHttpResponseError' do
      expect(defined? CrAPI::BadHttpResponseError).not_to be(nil)
      expect(CrAPI::BadHttpResponseError.superclass).to be(CrAPI::Error)
    end
  end
end
