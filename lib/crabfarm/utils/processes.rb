require 'childprocess'

ChildProcess.posix_spawn = true

module Crabfarm
  module Utils
    module Processes

      def self.start_logged_process(_name, _cmd, _logger, _env={})
        ro, wo = IO.pipe
        re, we = IO.pipe

        proc = ChildProcess.build(*_cmd)
        proc.environment.merge! _env
        proc.io.stdout = wo
        proc.io.stderr = we
        proc.start

        wo.close
        we.close

        Thread.new { ro.each_line { |l| _logger.info "[#{_name.upcase}] #{l}" } }
        Thread.new { re.each_line { |l| _logger.warn "[#{_name.upcase}] #{l}" } }

        proc
      end

    end
  end
end
