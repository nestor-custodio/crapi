# The CrAPI module houses the {CrAPI::Client CrAPI::Client} and {CrAPI::Proxy CrAPI::Proxy} classes
# in this gem.
#
module CrAPI
  # The canonical **crapi** gem version.
  #
  # This should only ever be updated *immediately* before a release; the commit that updates this
  # value should be pushed **by** the `rake release` process.
  #
  VERSION = '1.0.0'.freeze
end
