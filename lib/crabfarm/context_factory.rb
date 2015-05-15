module Crabfarm
  module ContextFactory

    def with_context(_memento=nil)
      ctx = build_context(_memento)
      begin
        ctx.prepare
        yield ctx
      ensure
        ctx.release
      end
    end

    def build_context(_memento=nil)
      if Crabfarm.live?
        Crabfarm.live.set_memento _memento
        Crabfarm::Context.new
      elsif _memento.nil?
        Crabfarm::Context.new
      else
        load_crabtrap_context _memento
      end
    end

    def load_crabtrap_context(_memento)
      require 'crabfarm/crabtrap_context'
      require 'crabfarm/modes/recorder/memento'
      m_path = Modes::Recorder::Memento.memento_path _memento
      raise ResourceNotFoundError.new "Could not find memento '#{_memento}'" unless File.exists? m_path
      Crabfarm::CrabtrapContext.new :replay, m_path
    end

    extend self
  end
end