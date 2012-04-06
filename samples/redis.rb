
require 'welo'
require 'welo-data'
require 'welo-data/adapters/redis'
require 'eventmachine'
require 'fiber'

class Post
  include Welo::Resource
  include Welo::Data::Resource
  attr_accessor :title, :text
  identify :default, [:id]
  perspective :default, [:title, :text]
end

class User
  include Welo::Resource
  include Welo::Data::Resource
  attr_accessor :name, :posts
  identify :default, [:name]
  perspective :default, [:name, :posts]
  relationship :posts, :Post, [:many]
end

EM.run do
  Fiber.new do
    redis = Welo::Data::Adapters::Redis.new

    jon = User.new(:name => 'jon', :posts => [])
    post = Post.new(:title => 'hello', :text => 'Hello World')
    jon.posts << post
    redis.save jon
    redis.save post # note that we need to save the post independently

    jon = redis.read(User, '/user/jon')
    # here we need to read posts because jon.posts is actually an array of Promise resources (i.e., pointer to other resources)
    # posts could be retrieve from another place (e.g., via an http adapter)
    jon.posts.map!{|promise| redis.read(Post, promise.path)} 

    puts jon.to_json(:default)
  end.resume
end
