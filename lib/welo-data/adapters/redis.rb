
require 'welo-data/adapter'
require 'em-redis'
require 'fiber'
require 'json'

module Welo::Data
  module Adapters
    class Redis < Welo::Data::Adapter
      attr_reader :redis
      def initialize(*args,&blk)
        @redis = EM::Protocols::Redis.connect(*args,&blk)
      end

      def read(klass, path)
        f = Fiber.current
        redis.get(path) do |dat|
          if dat
            if dat[0] == '/'  #we have a link
              Fiber.new { f.resume(read(klass,dat)) }.resume
            else              #we have a json object
              f.resume generate(klass, JSON.parse(dat))
            end
          else
            f.resume nil
          end
        end
        Fiber.yield
      end

      def pick(klass, keys, identifier=:default)
        mock = klass.new(keys, false)
        path = mock.path(identifier)
        res  = read klass, path
        res.merge! keys if res
        res
      end

      def delete(res, identifier=:default)
        key = res.path(identifier)
        redis.delete key
        key
      end

      def save(res, persp=:default, identifier=:default)
        key = res.path(identifier)
        redis.set(key, res.to_json(persp))
        key
      end

      def link(res, from=:default, to=:default)
        raise ArgumentError, "would create a loop" if from == to
        key = res.path(from)
        val = res.path(to)
        redis.set(key, val)
        key
      end

      def unlink(res, from)
        key = res.path(from)
        redis.delete(key)
        key
      end
    end
  end
end
