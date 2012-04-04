
require 'welo-data/adapter'
require 'em-mongo'
require 'fiber'
require 'json'

module Welo::Data
  module Adapters
    class Mongo < Adapter
      attr_reader :mongo

      def initialize(*args,&blk)
        #TODO: configure better
        @mongo = EM::Mongo::Connection.new('localhost').db('test')
      end

      def collection(klass)
        #TODO cache in a hash
        mongo.collection(klass.base_path)
      end

      def find_one(klass,query)
        f = Fiber.current
        m = collection(klass).find_one(query)
        m.callback do |doc|
          if doc
            dat  = doc['data']
            f.resume generate(klass, dat)
          else
            f.resume nil
          end
        end
        m.errback { f.resume nil }
        Fiber.yield
      end

      def find(klass, query)
        if block_given?
          f = Fiber.current
          collection(klass).find(query).each do |doc|
            if doc
              dat  = doc['data']
              f.resume generate(klass, dat)
            else
              f.resume nil
            end
          end

          while (obj = Fiber.yield) do
            yield obj
          end
        else
          Enumerator.new(self, :find, klass, query)
        end
      end

      def read(klass, path)
        find_one(klass, {'metadata.path' => path})
      end

      def pick(klass, keys, identifier=:default)
        mock = klass.new(keys, false)
        path = mock.path(identifier)
        res  = read(klass, path)
        res.merge! keys if res
        res
      end

      def delete(res, identifier=:default)
        key = res.path(identifier)
        collection(res.class).remove 'metadata.path' => key
        key
      end

      def save(res, persp=:default, identifier=:default, metadata={})
        key = res.path(identifier)
        query = metadata.merge('metadata.path' => key)
        dat = {'metadata' => {'path' => key}, 
          'data' => res.to_serialized_hash(persp)}
        collection(res.class).update(query, dat, {:upsert => true})
        key
      end
    end
  end
end
