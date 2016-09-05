# Liebre

## Intro

**Liebre stands for hare in spanish.**

This is a gem that handles RabbitMQ consumers, publishers and RPCs, based on [bunny](https://github.com/ruby-amqp/bunny).

* It allows to create classes that will be invoked everytime a message it's received in its subscribed queue. 
* It handles RPCs as a special Consumer where a callback message is returned to the exchange.
* You can use its Publisher to send message to an exchange.
* There is also a Publisher RPC method to send a message and wait for its response.

## Configuration
It is based on 2 config files:

* rabbitmq.yml: it contains RabbitMQ connection configurations and can be enviroment dependant (default path `config/rabbitmq.yml`), it must contain, at least the `default` connection
  * without environment set:
```
default:
  :host: localhost
  :port: 5672
  :user: guest
  :pass: guest
  :vhost: /
  :threaded: true
  :heartbeat: 2
```
  * with environment set:
```
development:
  default:
    :host: localhost
    :port: 5672
    :user: guest
    :pass: guest
    :vhost: /
    :threaded: true
    :heartbeat: 2
  rpc:
    :host: localhost
    :port: 5672
    :user: guest
    :pass: guest
    :vhost: rpc
    :threaded: true
    :heartbeat: 2
test:
  default:
    :host: localhost
    :port: 5672
    :user: guest
    :pass: guest
    :vhost: /
    :threaded: true
    :heartbeat: 2
  rpc:
    :host: localhost
    :port: 5672
    :user: guest
    :pass: guest
    :vhost: rpc
    :threaded: true
    :heartbeat: 2

production:
  ...
```

* liebre.yml (default path `config/liebre.yml`)
```
rpc_request_timeout: 5

consumers:
  some_consumer:
    class_name: MyConsumer
    rpc: false
    pool_size: 1
    exchange:
      name: "consumer_exchange"
      type: "fanout"
      opts:
        durable: false
    queue:
      name: "consumer_queue"
      opts:
        durable: false
    bind:
      routing_key: some_routing_key
        
  some_rpc:
    class_name: MyRPC
    rpc: true
    connection_name: rpc
    pool_size: 1
    exchange:
      name: "rpc_exchange"
      type: "fanout"
      opts:
        durable: false
    queue:
      name: "rpc_queue"
      opts:
        durable: false
  
publishers:
  some_publisher:
    exchange:
      name: "consumer_exchange"
      type: "fanout"
      opts:
        durable: false
  rpc_publisher:
    connection_name: rpc
    exchange:
      name: "rpc_exchange"
      type: "fanout"
      opts:
        durable: false
```

### Consumers

An entry for each consumer in your app, consumer options:
* `class_name` (mandatory): The class that will be invoked everytime a message is received
* `rpc` is a flag to specify the consumer behaviour (default false)
* `connection_name`: the name of the connection to use (default `default`)
* `pool_size` of the connection channel (default 1)
* `exchange` a hash of options:
  * `name`: the exchange name
  * `type`: the exchange type (fanout, direct or topic)
  * `opts`: options hash to pass to bunny exchange function
* `queue` a hash of options:
  * `name`: the queue name
  * `opts`: options hash to pass to bunny queue function
* `bind` a hash of options (optional):
  * `routing_key`: the binding routing key

### Publishers

An entry for each exchange you want to publish to, options:
* `connection_name`: the name of the connection to use (default `default`)
* `exchange` a hash of options:
  * `name`: the exchange name
  * `type`: the exchange type (fanout, direct or topic)
  * `opts`: options hash to pass to bunny exchange function

### Other configurations

`rpc_request_timeout`: set the timeout for an RPC request

### Change default paths and set env and Logger

You can change these defaults in an initializer with something like:

```
Liebre::Config.config_path = "your/custom/path"
Liebre::Config.connection_path = "your/custom/path"

Liebre::Config.env = "production"
Liebre::Config.logger = Logger.new(...)

```

## Usage

There are 2 different consumer usages: `Consumer` and `RPC`
There are 2 ways to publish a message: `enqueue` and `enqueue_and_wait`

### Consumer

You only need to create a class with this simple interface:

```
class MyConsumer
    
  def initialize payload, meta
    @payload = payload #the content of the message
    @meta = meta #the meta information (also called properties)
  end

  def call
    #do your stuff here
    #return :ack to anknowledge the message, 
    #return :reject to requeue it 
    #or return :error to send it to the dead-letter-exchange
    :ack
  end

end
```

Every time a message is received, a new instance of this class will be created.

### RPC

You only need to create a class with this simple interface:

```
class MyRPC
    
  def initialize payload, meta, callback
    @payload = payload #the content of the message
    @meta = meta #the meta information (also called properties)
    @callback = callback #a Proc that will publish an answer
  end

  def call
    #do your stuff here
    @callback.call("your response")
  end

end
```

Every time a message is received, a new instance of this class will be created.

### `enqueue`

```
publisher = Liebre::Publisher.new("some_publisher_name")

publisher.enqueue "hello", :routing_key => "consumer_queue"

publisher.enqueue "bye", :routing_key => "consumer_queue"

```

### `enqueue_and_wait` (alias `rpc`)

```
rpc_publisher = Liebre::Publisher.new("rpc_publisher")

response = publisher.enqueue_and_wait "hello", :routing_key => "consumer_queue"

another_response = publisher.rpc "bye", :routing_key => "consumer_queue"

```