require 'crabfarm/factories/decorable'

module Crabfarm
  module Factories
    module Context
      include Decorable

      def self.default_build(_memento)
        if _memento.nil?
          Crabfarm::Context.new
        else
          load_crabtrap_context _memento
        end
      end

      def self.load_crabtrap_context(_memento)
        require 'crabfarm/crabtrap_context'
        require 'crabfarm/modes/recorder/memento'
        m_path = Modes::Recorder::Memento.memento_path _memento
        raise ResourceNotFoundError.new "Could not find memento '#{_memento}'" unless File.exists? m_path
        Crabfarm::CrabtrapContext.new :replay, m_path
      end
    end
  end
end