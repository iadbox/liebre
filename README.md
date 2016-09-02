# Liebre

## Intro

**Liebre stands for hare in spanish.**

This is a gem that handles RabbitMQ consumers, publishers and RPCs, based on [bunny](https://github.com/ruby-amqp/bunny).

* It allows to create classes that will be invoked everytime a message it's received in its subscribed queue. 
* It handles RPCs as a special Consumer where a callback message is returned to the exchange.
* You can use its Publisher to send message to an exchange.
* There is also a Publisher RPC method to send a message and wait for its response.

## Usage
It is based on 2 config files:

* rabbitmq.yml: it contains RabbitMQ connection configuration and can be enviroment dependant (default path `config/rabbitmq.yml`)
  * without environment set:
```
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
  :host: localhost
  :port: 5672
  :user: guest
  :pass: guest
  :vhost: /
  :threaded: true
  :heartbeat: 2

test:
  :host: localhost
  :port: 5672
  :user: guest
  :pass: guest
  :vhost: /
  :threaded: true
  :heartbeat: 2

production:
  ...
```

* liebre.yml (default path `config/liebre.yml`)
```
rpc_request_timeout: 30

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
        
  some_rpc:
    class_name: MyRPC
    rpc: true
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
    exchange:
      name: "rpc_exchange"
      type: "fanout"
      opts:
        durable: false
```