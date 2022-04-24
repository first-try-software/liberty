# frozen_string_literal: true

require_relative "parsers/factory"

module Liberty
  module Adapters
    class Request
      PARSED_BODY = "parsed_body"
      ROUTER_PARAMS = "router.params"

      attr_reader :env

      def initialize(env = nil)
        @env = env
      end

      def headers
        @headers ||= env ? {
          accept_media_types: accept_media_types,
          preferred_media_type: preferred_media_type
        } : {}
      end

      def params
        @params ||= env ? all_params : {}
      end

      private

      def all_params
        form_params.merge!(body_params).merge!(url_params)
      end

      def accept_media_types
        @accept_media_types ||= rack_request.accept_media_types
      end

      def preferred_media_type
        accept_media_types.first
      end

      def form_params
        symbolize_keys(rack_request.params || {})
      end

      def body_params
        symbolize_keys(parsed_body || {})
      end

      def parsed_body
        Parsers::Factory.build(media_type: media_type).parse(body)
      end

      def body
        read_body = rack_request.body.read
        rack_request.body.rewind
        read_body
      end

      def media_type
        rack_request.media_type
      end

      def url_params
        env[ROUTER_PARAMS] || {}
      end

      def symbolize_keys(hash)
        hash.each_with_object({}) { |(key, value), obj| obj[key.to_sym] = value }
      end

      def rack_request
        @rack_request ||= Rack::Request.new(env)
      end
    end
  end
end
