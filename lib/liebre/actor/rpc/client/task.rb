require 'concurrent'

module Liebre
  module Actor
    module RPC
      class Client
        class Task

          def initialize
            @tasks = []
          end

          def every interval, &block
            task = Concurrent::TimerTask.new(execution_interval: interval, &block)
            tasks << task

            task.execute
          end

          def cancel_all
            tasks.each(&:shutdown)
            tasks.clear
          end

        private

          attr_reader :tasks

        end
      end
    end
  end
end
