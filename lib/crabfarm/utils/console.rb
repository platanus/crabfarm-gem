require 'json'
require 'inquirer'
require 'rainbow'
require 'rainbow/ext/string'

module Crabfarm
  module Utils
    module Console
      extend self

      COLOR_INFO = '888888'
      COLOR_QUESTION = '888888'
      COLOR_WARNING = :yellow
      COLOR_ERROR = :red
      COLOR_HIGHLIGHT = '00FF00'

      def system(_message)
        puts _message
      end

      def operation(_message)
        puts _message
      end

      def info(_message)
        puts _message.color COLOR_INFO
      end

      def result(_message)
        puts _message.color COLOR_HIGHLIGHT
      end

      def json_result(_data)
        if _data.nil?
          result 'nil'
        else
          result JSON.pretty_generate(_data).gsub(/(^|\\n)/, '  ')
        end
      end

      def warning(_message)
        puts _message.color COLOR_WARNING
      end

      def error(_message)
        puts _message.color COLOR_ERROR
      end

      def exception(_exc)
        error "#{_exc.class.to_s}: #{_exc.to_s}"
        backtrace _exc
      end

      def backtrace(_exc)
        _exc.backtrace.each { |i| info(i) }
      end

      def question(_question)
        Ask.input(_question.color COLOR_QUESTION)
      end

      def trap_errors(_context)
        begin
          yield
        rescue SystemExit, Interrupt
          raise
        rescue Exception => e
          error = "Error #{_context}"
          warning error + ', check log for more information'
          Crabfarm.logger.error error
          Crabfarm.logger.error e
        end
      end

    end
  end
end