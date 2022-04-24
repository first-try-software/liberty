# frozen_string_literal: true

module Liberty
  class Router
    class Printer
      VERBS = %w(GET HEAD POST PUT PATCH DELETE).freeze

      attr_reader :static, :dynamic, :memo, :stdout

      def initialize(static, dynamic, stdout = STDOUT)
        @static, @dynamic = static, dynamic
        @stdout = stdout
        @memo = []
      end

      def print
        gather_static_routes
        gather_dynamic_routes
        print_routes
      end

      private

      def gather_static_routes
        static.each do |verb, routes|
          routes.each do |path, endpoint|
            memo << { verb: verb, path: path, endpoint: endpoint }
          end
        end
      end

      def gather_dynamic_routes
        dynamic.each do |verb, trie|
          trie.print(verb, memo)
        end
      end

      def print_routes
        sorted_routes.each { |route| print_route(**route) }
      end

      def sorted_routes
        memo.sort_by { |route| "#{route[:path]}-#{VERBS.find_index(route[:verb])}" }
      end

      def print_route(verb:, path:, endpoint:)
        stdout.puts "#{pad(verb, 8)} #{pad(path, -50)} => #{endpoint}"
      end

      def pad(str, length)
        "%#{length}s" % str
      end
    end
  end
end
