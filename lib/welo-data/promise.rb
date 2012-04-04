

module Welo::Data
  #A Promise is a kind of pointer to some data given a link.
  Promise = Struct.new(:klass, :link) do
    def promise?
      true
    end

    def read
      klass.read link
    end

    def path(*val)
      link
    end
  end
end
