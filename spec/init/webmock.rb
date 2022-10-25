# Allow connections to webdriver urls
#
driver_urls = Webdrivers::Common.subclasses.map(&:base_url)
WebMock.disable_net_connect!(allow_localhost: true, allow: driver_urls)

WebMock.after_request do |request_signature, response|
  puts "Request #{request_signature} was made and #{response} was returned"
end
