# Liebre

A library to interact with AMQP servers.

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
  publishers: [
    {connection: :one,
     resources: {
       exchange: {name: "foo", type: "fanout"}}},
    {connection: :other,
     resources: {
       exchange: {name: "bar", type: "direct", opts: {durable: true}}}}
  ],
  consumers: [
    {connection: :one,
     handler: MyApp::Consumer,
     prefetch_count: 10,
     pool_size: 10,
     resources: {
       exchange: {name: "baz", type: "fanout"},
       queue: {name: "baz_queue"},
       bind: [{routing_key: "a_key"}, {routing_key: "another"}]}},
  ],
  rpc_clients: [
    {connection: :other,
     resources: {
       exchange: {name: "qux", type: "fanout"}}},
  ],
  rpc_servers: [
    {connection: :one,
     handler: MyApp::RPCServer,
     prefetch_count: 5,
     pool_size: 5,
     resources: {
       exchange: {name: "quux", type: "fanout"},
       queue: {name: "quux_queue"}}}
  ]
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

```
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

### Publisher

TODO

### Consumer

TODO

### RPC Client

TODO

### RPC Server

TODO
