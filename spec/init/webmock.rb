# Allow connections to webdriver urls
#
driver_urls = Selenium::WebDriver::Chromium::Driver.subclasses.map(&:base_url)
WebMock.disable_net_connect!(allow_localhost: true, allow: driver_urls)
