require 'grape'
require 'crabfarm/support/custom_puma'
require 'crabfarm/engines/async_state_manager'

module Crabfarm
  module Modes
    class Server

      class API < Grape::API

        DEFAULT_WAIT = 60.0 * 5

        format :json
        prefix :api

        rescue_from Grape::Exceptions::ValidationErrors do |e|
          rack_response({ errors: e.as_json }.to_json, 400)
        end

        rescue_from Crabfarm::ApiError do |e|
          rack_response(e.to_json, e.code)
        end

        helpers do
          def evaluator
            Server.evaluator
          end

          def wait
            params.fetch(:wait, DEFAULT_WAIT)
          end

          def print_state(_state)
            {
              name: _state.name,
              params: _state.params,
              doc: _state.doc,
              elapsed: _state.elapsed
            }
          end
        end

        desc "Return the current crawler status."
        params do
          optional :wait, type: Float
        end
        get :state do
          print_state evaluator.wait_for_state wait
        end

        desc "Change the crawler state"
        params do
          requires :name, type: String, desc: "Crawler state name"
          optional :wait, type: Float
        end
        put :state do
          print_state evaluator.transition params[:name], params[:params], wait
        end
      end

      def self.evaluator
        @@evaluator
      end

      def self.serve(_context, _options)
        @@evaluator = Engines::AsyncStateManager.new _context
        @@evaluator.start
        begin
          Support::CustomPuma.run API, _options
        rescue SystemExit, Interrupt
          # just finish
        ensure
          @@evaluator.stop
        end
      end

    end
  end
end

