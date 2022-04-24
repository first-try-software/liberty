# frozen_string_literal: true

require_relative 'node'

module Liberty
  class Router
    class Trie
      PATH_SEPARATOR = '/'

      def initialize
        @root = Node.new
      end

      def add_route(path, endpoint)
        traverse(path) { |segment, node| node.add(segment) }.attach(endpoint)
      end

      def find_route(path)
        route_params = {}
        node = traverse(path) do |segment, node|
          node.find(segment) { |params| route_params.merge!(params) }
        end

        yield(route_params) if node && block_given?

        node&.endpoint
      end

      def print(verb, routes)
        @root.print(verb, routes)
      end

      private

      def traverse(path)
        _, *segments = path.split(PATH_SEPARATOR)
        segments.reduce(@root) do |node, segment|
          break unless node
          yield(segment, node)
        end
      end
    end
  end
end
