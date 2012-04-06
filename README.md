# Welo::Data

Welo::Data is a library for Welo persisting and retriving Welo resources.
Welo::Data overloads initialize, hence you should not inject Welo::Data::Resource in an object unless you know what you're doing.

Within Welo, all resources are identified by their path.

Welo::Data resources do not have all the semantics you may dream of when
building an application with lots of searches, but it fits well cases where you
create/pick/save/delete items one by one.

Welo::Data ships with (simple) adapaters for:
- em-redis
- em-mongodb
- em-http-request

These adapters use EventMachine and Fiber.
A minimal knowledge of these is preferred but not mandatory.


## Installation

Add this line to your application's Gemfile:

    gem 'welo-data'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install welo-data

## Usage

Please have a look at examples in ./samples/

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
