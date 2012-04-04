
require 'welo-data'

module Welo::Data
  class Adapter
    def generate(klass,hash)
      klass.new(hash, true)
    end
  end
end
