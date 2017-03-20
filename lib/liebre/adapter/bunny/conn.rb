module Liebre
  module Adapter
    class Bunny
      class Conn
        include Interface::Conn

        attr_reader :opts

        def initialize opts
          @opts = opts
        end

        def start
          session.start
        end

        def open_channel
          Chan.new(session.create_channel)
        end

        def stop
          session.stop
        end

        def session
          @session ||= ::Bunny.new(opts)
        end

      end
    end
  end
end
