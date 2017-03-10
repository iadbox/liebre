require 'concurrent'
require 'securerandom'

module Liebre
  module Actor
    module RPC
      class Client
        class Pending

          Request = Struct.new(:ivar, :expiration_time)

          def initialize
            @pending = {}
          end

          def add timeout
            new_ivar.tap do |ivar|
              correlation_id = new_correlation_id()
              yield(correlation_id)

              store(correlation_id, ivar, timeout)
            end
          end

          def finish correlation_id, response
            pending.delete(correlation_id).tap do |request|
              request.ivar.set(response) if request
            end
          end

          def expire
            now = current_time

            pending.delete_if do |_correlation_id, request|
              now - request.start_time > timeout
            end
          end

        private

          def store correlation_id, ivar, timeout
            expiration_time = current_time + timeout

            pending[correlation_id] = Request.new(ivar, expiration_time)
          end

          def new_correlation_id
            SecureRandom.urlsafe_base64
          end

          def new_ivar
            Concurrent::IVar.new
          end

          def current_time
            Time.now
          end

          attr_reader :pending

        end
      end
    end
  end
end
