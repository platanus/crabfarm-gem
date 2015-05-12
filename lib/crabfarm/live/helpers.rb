module Crabfarm
  module Live
    module Helpers
      extend self

      def inject_script(_driver, _path)
        _driver.execute_script("
          (function() {
            var script = document.createElement('script');
            script.setAttribute('src','#{_path}');
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

    end
  end
end
