
require 'welo-data/adapter'
require 'eventmachine'
require 'em-http-request'
require 'fiber'
require 'json'

module Welo::Data
  module Adapters
    class Http < Adapter
      attr_reader :host, :port, :root

      def initialize(host,port=80,root='/')
        @host = host.freeze
        @port = port
        @root = root.freeze
      end

      def http_post(url,data)
        f = Fiber.current
        http = EM::HttpRequest.new(url).post(:body => data)
        http.errback {f.resume nil}
        http.callback {f.resume url}
        Fiber.yield
      end

      def http_get(url)
        f = Fiber.current
        http = EM::HttpRequest.new(url).get
        http.errback { f.resume nil }
        http.callback {
          json = http.response
          f.resume JSON.parse(json)
        }
        Fiber.yield
      end

      def pick(klass, params, identifier=:default)
        mock = klass.new(params)
        get klass, mock.path(identifier)
      end

      def url(path)
        ['http://', host, ":#{port}", path].join
      end

      def get(klass, path)
        path = File.join('', root, path)
        get_url klass, url(path)
      end

      def get_url(klass, url)
        hash = http_get url
        generate hash if hash
      end

      def post(res, persp=:default, identifier=:default)
        http_post url(res.path(identifier)), res.to_json(persp)
      end
    end
  end
end

