# Liebre

A library to interact with AMQP servers.

Liebre stands for hare in spanish.

## Installation

Add this line to your application's Gemfile:

    gem 'liebre'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install liebre

## Introduction

The Liebre library provides 4 abstractions, or **actors**, to interact with the server:

  * **Publisher**: Publishes messages to an exchange
  * **Consumer**: Binds a queue to an exchange, and consumes messages
  * **RPC Client**: Publishes messages to an exchange and blocks until a response is received through an exclusive queue
  * **RPC Server**: Binds a queue to an exchange, consumes messages, and replies the caller by putting a message at the specified queue

Each actor has its own thread and its own channel.  Some actors (Consumer and RPC Server)
also have their own thread pool in order to be able to handle messages concurrently.

It leverages [concurrent-ruby](https://github.com/ruby-concurrency/concurrent-ruby) `Concurrent::Async` mixin to
implement the actors.

## Configuration

Liebre accepts the following configuration options:

```ruby
Liebre.configure do |config|
  config.logger      = $logger
  config.adapter     = Liebre::Adapter::Bunny
  config.connections = connections_config
  config.actors      = actors_config
end
```

### Logger

The logger configuration option is optional and defaults to `Logger.new(nil)`.
Liebre will log in the following events:

  * An actor is started
  * An actor is stopped
  * Some error happened on the actor's thread

Any other logging should be done from the application.

### Adapter

It specifies the adapter to use to interact with the server. The only adapter that ships with
the library is the `Liebre::Adapter::Bunny` adapter that uses the `bunny` gem.

**IMPORTANT**: Note that you should have the `bunny` gem available to use the
`Liebre::Adapter::Bunny` adapter.

### Connections

On startup Liebre will establish a set of connections with one or more AMQP servers. Actors can be
started on any of this connections.

```ruby
{one: {host: "foo.com", port: 123},
 other: {}}
```

The example above will establish two connections, the configuration for each connection
will be given with no modification to the adapter.

### Actors

The configuration of all actors:

```ruby
{
  publishers: {
    my_publisher: {connection: :one,
                   resources: {
                     exchange: {name: "foo", type: "fanout"}}},
    my_other_pub: {connection: :other,
                   resources: {
                     exchange: {name: "bar", type: "direct", opts: {durable: true}}}}
  },
  consumers: {
    my_consumer: {connection: :one,
                  handler: MyApp::Consumer,
                  prefetch_count: 10,
                  pool_size: 10,
                  resources: {
                    exchange: {name: "baz", type: "fanout"},
                    queue: {name: "baz_queue"},
                    bind: [{routing_key: "a_key"}, {routing_key: "another"}]}},
  },
  rpc_clients: {
    my_rpc_client: {connection: :other,
                    resources: {
                      exchange: {name: "qux", type: "fanout"}}},
  },
  rpc_servers: {
    my_rpc_server: {connection: :one,
                    handler: MyApp::RPCServer,
                    prefetch_count: 5,
                    pool_size: 5,
                    resources: {
                      exchange: {name: "quux", type: "fanout"},
                      queue: {name: "quux_queue"}}}
  }
}
```

The example above will start 5 actors:

  * A publisher to the `"foo"` exchange over the connection `:one`
  * A publisher to the `"bar"` exchange over the connection `:other`
  * A consumer of the "baz" queue that will consume messages over the connection `:one` and process them by running `MyApp::Consumer` handler on a pool of 10 dedicated threads
  * A rpc client to the `"qux"` exchange over the connection `:other`
  * A rpc server of the "quux" queue that will consume messages over the connection `:one` and process them by running `MyApp::RPCServer` handler on a pool of 5 dedicated threads

Common options:

  * `:connection` - The name of the connection to open the channel over
  * `:resources` - Configuration about queues and exchanges. Depends on the actor

Options for message handlers (Consumer and RPC Server):

  * `:handler` - The class to use to handle messages. Its interface depends on the actor
  * `:prefetch_count` - The prefetch count of the actor's channel
  * `:pool_size` - The number of dedicated threads that will be used to handle messages concurrently

## Start the engine

### On an existing service

A `Liebre::Engine` is an object that is able to start and stop a given configuration.

```ruby
require 'yaml'
require 'liebre'

config = Liebre::Config.new

config.adapter     = Liebre::Adapter::Bunny
config.connections = YAML.load_file("config/rabbitmq.yml")
config.actors      = YAML.load_file("config/liebre.yml")

engine = Liebre::Engine.new(config)
engine.start
```

The example above will establish the specified connections and start all actors with
their own threads and thread pools.

Usually only one engine is required per application. To simplify the process, a default
engine that uses the default config is provided.

```ruby
require 'liebre'

Liebre.configure do |config|
  config.adapter     = Liebre::Adapter::Bunny
  config.connections = YAML.load_file("config/rabbitmq.yml")
  config.actors      = YAML.load_file("config/liebre.yml")
end

Liebre.engine.start
```

This kind of startup is commonly used on rack applications. The previous code
can be called from a Rails initializer.

### As a standalone application

If you wish to start Liebre as a standalone application `Liebre::Runner` is provided.

```ruby
require 'liebre'

Liebre.configure do |config|
  # some config
end

runner = Liebre::Runner.new(engine: Liebre.engine)
runner.run
```

The example above starts the runner with the default engine

It sets up some system signals in order to respond gracefully to unix `kill`
and sleeps the main thread forever.

The previous pattern is so common that a shortcut is provided:

```ruby
require 'liebre'

Liebre.configure do |config|
  # some config
end

Liebre.start
```

### Start partially

Imagine the following setup: You have an application that may be started as a rack
application and also as a worker with no rack interface to consume from rabbitmq as
a background tasks system.

When you start the application with rack you may use publishers or rpc clients, but
you don't want to start the consumers and rpc servers.

When you start the application with `Liebre::Runner` you want all actors to start.

To handle this kind of scenarios `Liebre` keeps track of the already started actors
and prevents them to start twice on a given engine.

A solution to this case may be the following:

Start all publishers and consumers on an initialized that will be shared between
both ways to start the application:

```ruby
require 'liebre'

Liebre.configure do |config|
  # some config
end

Liebre.engine.start(only: [:publishers, :rpc_clients])
```

This code will configure `Liebre` and starts all publishers and rpc clients.

When you start your application with `Liebre::Runner` you can do the following:

```ruby
# run all your initializers including the one above

require 'liebre'
Liebre.start
```

This code will start all actors, and publishers and rpc clients will only be started
once.

## Actors

Once a liebre engine has been started a `Liebre::Repository` has been populated with all actors
that can be fetched by name.

```ruby
# ... start the engine
repo = engine.repo

publisher_1 = repo.publisher(:my_publisher)
publisher_2 = repo.publisher(:my_other_pub)
consumer    = repo.consumer(:my_consumer)
rpc_client  = repo.rpc_server(:my_rpc_server)
rpc_server  = repo.rpc_server(:my_rpc_server)
```

### Publisher

A publisher is an actor that declares an exchange on startup and provides a method to publish
messages to that exchange.

The `:resources` section of the actor's configuration requires the exchange specification:

```ruby
require 'liebre'

Liebre.configure do |config|
  config.adapter = Liebre::Adapter::Bunny
  config.connections = {default: {}}

  config.actors = {
    publishers: {
      my_pub: {
        connection: :default,
        resources: {
          exchange: {name: "foo",
                     type: "direct",
                     opts: {durable: true}}
        }
      }
    }
  }
end

Liebre.engine.start

publisher = Liebre.repo.publisher(:my_pub)
publisher.publish("some_data")
publisher.publish("more_data", :routing_key => "my_key")
```

The exchange specification:

  * `:name` - The name of the exchange
  * `:type` - The exchange type (`"direct"`, `"fanout"`, etc)
  * `:opts` - (defaults to `{}`) The exchange options

Once started the `#publish` method can be used to send messages to the configured
exchange.

### Consumer

A consumer is an actor that declares an exchange, a queue and binds them on startup.
It owns a thread pool to handle consumed messages.

After declaration it subscribes to the queue and starts consuming messages. Once a message
is consumed a handler for that message is started in a thread of the pool.

The handler class must implement the following interface:

  * `#initialize` receives 3 arguments: `payload`, `meta`, and `callback`.
  * `#call`

The handler class is initialized with that 3 arguments:

  * `payload` - The actual content of the message
  * `meta` - Message metadata that includes the headers and other information (depends on the adapter)
  * `callback` - An object that responds to `#ack`, `#nack`, and `#reject`

```ruby
class MyHandler

  def initialize payload, meta, callback
    @payload  = payload
    @callback = callback
  end

  def call
    case payload
      when "0" then zero()
      when "1" then one()
      else raise "unknown!"
    end
  end

private

  def zero
    puts "yay!"
    callback.ack()
  end

  def one
    puts "wtf!"
    callback.reject(requeue: false)
  end

  attr_reader :payload, :callback

end
```

The handler above will print `"yay!"` and ack the message when the payload is `"0"`,
print `"wtf!"` and reject the message when the payload is `"1"`, and will raise (and therefore
will be rejected by liebre) when the handler raises an error.

The `:resources` section of the actor's configuration requires the exchange and the queue,
and may include binding options.

```ruby
require 'liebre'

Liebre.configure do |config|
  config.adapter = Liebre::Adapter::Bunny
  config.connections = {default: {}}

  config.actors = {
    consumers: {
      my_con: {
        connection: :default,
        handler: MyHandler,
        prefetch_count: 5,
        pool_size: 5,
        resources: {
          exchange: {name: "foo",
                     type: "direct",
                     opts: {durable: true}},
          queue: {name: "bar",
                  opts: {durable: true}},
          bind: [{routing_key: "one"},
                 {routing_key: "other"}]
        }
      }
    }
  }
end

Liebre.engine.start
```

The exchange specification is the same as for the publisher.

The queue specification:

  * `:name` - The name of the queue
  * `:opts` - (defaults to `{}`) The queue options

The bind specification is optional and defaults to `{}`. `:bind` value may be:

  * not present - the queue is bound to the exchange once with `{}` as options
  * a hash - the queues is bound once to the exchange with that options
  * a list of hashes - the queues is bound to the exchange once per hash of options

The example above declares the exchange `"foo"`, declares the queue `"bar"`,
binds the queue to the exchange twice: one with the `"one"` routing key and
another with the `"other"` routing key).

It starts a thread pool of 5 threads and starts consuming messages.

For each message the consumer receives a handler is instantiated and `#call` is called on
it in one of the threads of its pool.

### RPC Client

A RPC client is an actor that declares an exchange, and declares a temporary queue with
the options `exclusive`, and `auto_delete`.

After declaration it subscribes to the queue.

The `:resources` section of the rpc client configuration must specify the exchange.

```ruby
require 'liebre'

Liebre.configure do |config|
  config.adapter = Liebre::Adapter::Bunny
  config.connections = {default: {}}

  config.actors = {
    rpc_client: {
      my_client: {
        connection: :default,
        resources: {
          exchange: {name: "foo",
                     type: "direct",
                     opts: {durable: true}},
          queue: {prefix: "client_responses"}
        }
      }
    }
  }
end

Liebre.engine.start

client = Liebre.repo.rpc_client(:my_pub)
client.request("data")                     # => rpc server response (or nil on timeout, 5 seconds by default)
client.request("data", routing_key: "bar") # => rpc server response (or nil on timeout, 5 seconds by default)
client.request("data", {}, 15)             # => rpc server response (or nil on timeout after 15 seconds)
```

The exchange specification is the same as for the publisher.

The queue specification is optional and includes a prefix for the queue's name. The name of the
queue will be that prefix followed by a random token, for example: `"client_responses_q23jrefdzXw"`.

When a request is performed the client will block until the response is received or the timeout is reached.

### RPC Server

A rpc server is an actor that declares an exchange, a queue and binds them on startup.
It owns a thread pool to handle requests.

After declaration it subscribes to the queue and starts consuming messages. Once a message
is consumed a handler for that message is started in a thread of the pool.

The handler class must implement the following interface:

  * `#initialize` receives 3 arguments: `payload`, `meta`, and `callback`.
  * `#call`

The handler class is initialized with that 3 arguments:

  * `payload` - The actual content of the message
  * `meta` - Message metadata that includes the headers and other information (depends on the adapter)
  * `callback` - An object that responds to `#reply`

```ruby
class MyHandler

  def initialize payload, meta, callback
    @payload  = payload
    @callback = callback
  end

  def call
    case payload
      when "0" then callback.reply("zero")
      when "1" then callback.reply("one")
      else raise "unknown!"
    end
  end

private

  attr_reader :payload, :callback

end
```

The handler above will reply to the client with "zero" when payload is "0",
reply with "one" when the payload is "1", and will raise (and therefore not reply)
when the handler raises error.

The `:resources` section of the actor's configuration requires the exchange and the queue,
and may include binding options.

```ruby
require 'liebre'

Liebre.configure do |config|
  config.adapter = Liebre::Adapter::Bunny
  config.connections = {default: {}}

  config.actors = {
    rpc_servers: {
      my_rpc_server: {
        connection: :default,
        handler: MyHandler,
        prefetch_count: 5,
        pool_size: 5,
        resources: {
          exchange: {name: "foo",
                     type: "direct",
                     opts: {durable: true}},
          queue: {name: "bar",
                  opts: {durable: true}},
          bind: [{routing_key: "one"},
                 {routing_key: "other"}]
        }
      }
    }
  }
end

Liebre.engine.start
```

The exchange specification is the same as for the publisher.
The queue and bind specifications are the same as for the consumer.

The example above declares the exchange `"foo"`, declares the queue `"bar"`,
binds the queue to the exchange twice: one with the `"one"` routing key and
another with the `"other"` routing key).

It starts a thread pool of 5 threads and starts consuming requests.

For each message the consumer receives it instantiates and runs `#call` on
the new handler in one of the threads of its pool.
