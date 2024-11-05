# frozen_string_literal: true

require "graphql/fragment_cache/rails/cache_key_builder"

module GraphQL
  module FragmentCache
    class Railtie < ::Rails::Railtie # :nodoc:
      # Provides Rails-specific configuration,
      # accessible through `Rails.application.config.graphql_fragment_cache`
      module Config
        class << self
          def store=(store)
            # Handle both:
            #   store = :memory_store
            #   store = :mem_cache, ENV['MEMCACHE']
            #
            # ActiveSupport 7.1 might raise a warning if coder isn't provided
            #   (in case cache_format_version wasn't explicitly set)
            if store == :null_store && Rails.env.test? && Rails.version.to_f == 7.1
              store = [:null_store, coder: ActiveSupport::Cache::SerializerWithFallback::PassthroughWithFallback]
            end

            if store.is_a?(Symbol) || store.is_a?(Array)
              store = ActiveSupport::Cache.lookup_store(store)
            end

            FragmentCache.cache_store = store
          end
        end
      end

      config.graphql_fragment_cache = Config

      if ENV["RACK_ENV"] == "test" || ENV["RAILS_ENV"] == "test"
        initializer "graphql-fragment_cache" do
          config.graphql_fragment_cache.store = :null_store
        end
      end
    end
  end
end
