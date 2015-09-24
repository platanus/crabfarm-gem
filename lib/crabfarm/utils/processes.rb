require 'childprocess'
require 'crabfarm/utils/stream_dumper'

ChildProcess.posix_spawn = true

module Crabfarm::Utils

  module Processes
    def self.start_logged_process(_name, _cmd, _logger, _env={})

      ro, wo = IO.pipe
      re, we = IO.pipe

      proc = ChildProcess.build(*_cmd)
      proc.environment.merge! _env
      proc.io.stdout = wo
      proc.io.stderr = we
      proc.start

      # close write endpoints after fork
      wo.close
      we.close

      # register log consumers
      StreamDumper.register_stream(ro) { |l| _logger.info "[#{_name.upcase}] #{l}" }
      StreamDumper.register_stream(re) { |l| _logger.warn "[#{_name.upcase}] #{l}" }

      proc
    end
  end

end

