# frozen_string_literal: true

require_relative 'router/trie'
require_relative 'router/printer'

module Liberty
  class Router
    GET = 'GET'
    HEAD = 'HEAD'
    POST = 'POST'
    PUT = 'PUT'
    PATCH = 'PATCH'
    DELETE = 'DELETE'
    REQUEST_METHOD = 'REQUEST_METHOD'
    PATH_INFO = 'PATH_INFO'
    ROUTER_PARAMS = 'router.params'
    DYNAMIC_PREFIX = /:/.freeze
    NOT_FOUND_RESPONSE = [404, { 'Content-Length' => '9' }, ['Not Found']].freeze

    def initialize
      @apps = {}
      @static = Hash.new { |h, k| h[k] = {} }
      @dynamic = {}
    end

    def get(path, to:)
      register_route(GET, path, to)
      register_route(HEAD, path, to)
    end

    def post(path, to:)
      register_route(POST, path, to)
    end

    def put(path, to:)
      register_route(PUT, path, to)
    end

    def patch(path, to:)
      register_route(PATCH, path, to)
    end

    def delete(path, to:)
      register_route(DELETE, path, to)
    end

    def call(env)
      endpoint = find_endpoint(env[REQUEST_METHOD], env[PATH_INFO]) { |params| env[ROUTER_PARAMS] = params }
      endpoint ? endpoint.call(env) : NOT_FOUND_RESPONSE
    end

    def print(stdout = STDOUT)
      Printer.new(@static, @dynamic, stdout).print
    end

    private

    def register_route(verb, path, to)
      dynamic?(path) ? register_dynamic_route(verb, path, to) : register_static_route(verb, path, to)
    end

    def find_endpoint(verb, path, &block)
      find_static(verb, path, &block) || find_dynamic(verb, path, &block)
    end

    def find_static(verb, path, &block)
      @static[verb][path].tap { |endpoint| endpoint && block.call({}) }
    end

    def find_dynamic(verb, path, &block)
      dynamic(verb).find_route(path, &block)
    end

    def dynamic?(path)
      DYNAMIC_PREFIX.match?(path)
    end

    def dynamic(verb)
      @dynamic[verb] ||= Trie.new
    end

    def register_dynamic_route(verb, path, to)
      @dynamic[verb] ||= Trie.new
      @dynamic[verb].add_route(path, to)
    end

    def register_static_route(verb, path, to)
      @static[verb][path] = to
    end
  end
end
