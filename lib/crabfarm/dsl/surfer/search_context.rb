module Crabfarm
  module Dsl
    module Surfer
      class SearchContext
        include Enumerable
        extend Forwardable

        TIMEOUT = 10.0 # Default timeout for waiting operations

        attr_accessor :elements, :parent

        def_delegators :elements, :length, :count, :empty?

        def initialize(_elements, _parent)
          @elements = _elements
          @parent = _parent
        end

        def root
          @parent.root
        end

        def each
          elements.each { |el| yield child_context [el] }
        end

        def [](*args)
          if args[0].is_a? String or args[0].is_a? Symbol
            attribute args[0]
          else
            child_context Array(elements.send(:[],*args))
          end
        end

        def first
          if elements.first.nil? then nil else child_context [elements.first] end
        end

        def last
          if elements.last.nil? then nil else child_context [elements.last] end
        end

        def element!
          raise EmptySetError.new("This set is empty", self) if empty?
          elements.first
        end

        def classes
          wrap_errors { (element!['class'] || '').split(' ') }
        end

        def search(_selector=nil, _options={})
          _options[:css] = _selector if _selector

          wait_mode = _options.delete :wait
          if wait_mode

            # retrieve timeout
            timeout = _options.delete :timeout
            timeout = TIMEOUT if timeout.nil?

            # use a selenium timeout
            wrap_errors do
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

                child_context new_elements if ok
              end
            end
          else
            child_context search_elements(_options)
          end
        end

        def fill(_value)
          wrap_errors do
            element!.clear
            element!.send_keys _value
          end
        end

        def to_html
          elements.map { |e| e['outerHTML'] }.join
        end

        # Any methods missing are forwarded to the main element (first).
        def method_missing(_method, *_args, &_block)
          wrap_errors do
            m = /^(.*)_all$/.match _method.to_s
            if m then
              return [] if empty?
              elements.map { |e| e.send(m[1], *_args, &_block) }
            else
              element!.send(_method, *_args, &_block)
            end
          end
        end

        def respond_to?(_method, _include_all=false)
          return true if super
          m = /^.*_all$/.match _method.to_s
          if m then
            return true if empty?
            elements.first.respond_to? m[1], _include_all
          else
            return true if empty?
            elements.first.respond_to? _method, _include_all
          end
        end

      private

        def child_context(_elements)
          SearchContext.new _elements, self
        end

        def wrap_errors
          begin
            yield
          rescue Selenium::WebDriver::Error::WebDriverError => e
            raise WebdriverError.new e, self
          end
        end

        def search_elements(_options)
          wrap_errors do
            elements.inject([]) do |r, element|
              r + element.find_elements(_options)
            end
          end
        end

      end
    end
  end
end
