require 'crabfarm/utils/webdriver'

module Crabfarm
  module Live
    module Interactable

      def self.included(klass)
        klass.extend ClassMethods
      end

      module ClassMethods

        def live(_options={}, &_setup)
          @delegate = _options[:delegate]
          @setup = _setup
        end

        def live_rspec?
          @setup.nil?
        end

        def live_delegate
          @delegate
        end

        def live_setup
          @setup
        end

      end

      # Tooling

      def highlight(_elements)
        if Crabfarm.live?
          if _elements.respond_to? :webdriver_elements
            _elements = _elements.webdriver_elements
          end

          if _elements.is_a? String
            _elements = Crabfarm.live.primary_driver.find_elements(css: _elements)
          end

          Utils::Webdriver.set_style _elements, "border: 3px solid yellow;"
        end
      end

    end
  end
end
