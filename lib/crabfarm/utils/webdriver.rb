module Crabfarm
  module Utils
    module Webdriver
      extend self

      def inject_script(_driver, _path)
        _driver.execute_script("
          (function() {
            var script = document.createElement('script');
            script.async = false;
            script.src = '#{_path}';
            document.head.appendChild(script);
          })();
        ")
      end

      def inject_style(_driver, _path)
        _driver.execute_script("
          (function() {
            var link  = document.createElement('link');
            link.setAttribute('rel','stylesheet');
            link.setAttribute('type','text/css');
            link.setAttribute('href','#{_path}');
            link.setAttribute('media','all');
            document.head.appendChild(link);
          })();
        ")
      end

      def set_style(_elements, _style)
        return if _elements.size == 0
        # Not sure about using a bridge method directly here...
        _elements.first.send(:bridge).executeScript("
          for(var i = 0, l = arguments[0].length; i < l; i++) {
            arguments[0][i].setAttribute('style', arguments[1]);
          }
        ", _elements, _style)
      end

    end
  end
end