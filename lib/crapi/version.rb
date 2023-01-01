# The Crapi module houses the {Crapi::Client Crapi::Client} and {Crapi::Proxy Crapi::Proxy} classes
# in this gem.
#
module Crapi
  # The canonical **crapi** gem version.
  #
  # This should only ever be updated *immediately* before a release; the commit that updates this
  # value should be pushed **by** the `rake release` process.
  #
  VERSION = '0.1.3'.freeze
end
