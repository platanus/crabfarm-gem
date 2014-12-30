module Crabfarm
  module Dsl
    module Surfer
      class SearchContext
        include Enumerable
        extend Forwardable

        TIMEOUT = 10.0 # Default timeout for waiting operations

        def initialize(_elements, _parent)
          @elements = _elements
          @parent = _parent
        end

        # return the context's root context
        def root_context
          return @parent.root_context if @parent
          self
        end

        # return the context's parent context
        def parent_context
          @parent
        end

        # forward read-only array methods to context
        def_delegators :context, :each, :[], :length, :count, :empty?, :first, :last

        # yield individual SearchContext for each element contained in this result
        def explode(&_block)
          return enum_for(__method__) if _block.nil?
          context.each do |el|
            _block.call SearchContext.new([el], self)
          end
        end

        # searches for elements that match a given selector
        def search(_selector=nil, _options={})
          _options[:css] = _selector if _selector

          wait_mode = _options.delete :wait
          if wait_mode

            # retrieve timeout
            timeout = _options.delete :timeout
            timeout = TIMEOUT if timeout.nil?

            # use a selenium timeout
            wait = Selenium::WebDriver::Wait.new(timeout: timeout)
            wait.until do
              new_elements = search_elements _options

              # test wait condition
              ok = case wait_mode
              when :present then (new_elements.length > 0)
              when :visible then (new_elements.length > 0 and new_elements.first.displayed?)
              when :enabled then (new_elements.length > 0 and new_elements.first.displayed? and new_elements.first.enabled?)
              when :not_present then (new_elements.length == 0)
              when :not_visible then (not new_elements.any? { |e| e.displayed? })
              else
                raise SetupError.new "Invalid wait mode '#{wait_mode}'"
              end

              SearchContext.new new_elements, self if ok
            end
          else
            SearchContext.new search_elements(_options), self
          end
        end

        # clears and sends_keys to this context main element
        def fill(_value)
          raise EmptySetError.new('Cannot call \'fill\' on an empty set', self) if empty?
          wrap_errors do
            context.first.clear
            context.first.send_keys _value
          end
        end

        # Any methods missing are forwarded to the main element (first).
        def method_missing(_method, *_args, &_block)
          wrap_errors do
            m = /^(.*)_all$/.match _method.to_s
            if m then
              return [] if empty?
              context.map { |e| e.send(m[1], *_args, &_block) }
            else
              raise EmptySetError.new("Cannot call '#{_method}' on an empty set", self) if empty?
              context.first.send(_method, *_args, &_block)
            end
          end
        end

        def respond_to?(_method, _include_all=false)
          return true if super
          m = /^.*_all$/.match _method.to_s
          if m then
            return true if empty?
            context.first.respond_to? m[1], _include_all
          else
            return true if empty?
            context.first.respond_to? _method, _include_all
          end
        end

      private

        # wrap every selenium errors that happen inside block.
        def wrap_errors
          begin
            yield
          rescue Selenium::WebDriver::Error::WebDriverError => e
            raise WebdriverError.new e, self
          end
        end

        # base filtering method, expands current context
        def search_elements(_options)
          wrap_errors do
            context.inject([]) do |r, element|
              r + element.find_elements(_options)
            end
          end
        end

        # returns the current context
        def context
          @elements
        end

      end
    end
  end
end
