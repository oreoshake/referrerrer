require 'selenium-webdriver'
require './referrerrer'
require 'pry'

VERSIONS = {
  ie: [8, 9, 10, 11],
  safari: [6, '6.1', 7, 8]
  # chrome: [39, 40, 41, 42],
  # firefox: [35, 36, 37]
}

def test_referrers(browser, version)
  caps = Selenium::WebDriver::Remote::Capabilities.new
  caps["browser"] = browser.to_s.upcase
  caps["browser_version"] = "#{version}"

  if browser == :safari
    caps["os"] = "OS X"
    case version
    when 6
      caps["os_version"] = "Lion"
    when '6.1'
      caps["os_version"] = "Mountain Lion"
    when 7
      caps["os_version"] = "Mavericks"
    when 8
      caps["os_version"] = "Yosemite"
    else
      raise 'fail'
    end
  else
    caps["os"] = "Windows"
    caps["os_version"] = "7"
  end

  caps["browserstack.debug"] = "true"
  caps["name"] = "Referrer spec testing"


  driver = Selenium::WebDriver.for(:remote,
    :url => "http://neil99:#{ENV['BROWSERSTACK_PW']}@hub.browserstack.com/wd/hub",
    :desired_capabilities => caps)


  DIRECTIVE_VALUES.each do |value|
    puts "****"
    driver.navigate.to "http://referrerrerr.herokuapp.com/#{value}"
    puts "Page: #{driver.current_url}"
    element = driver.find_element(:css => "a[href=\"#{value}\"]")
    element.click
    puts "Page: #{driver.current_url}"
    referrer = driver.find_element(:css => 'data').text
    puts "Referrer: #{referrer}"
  end
rescue StandardError => e
  puts "Error #{e.inspect}"
ensure
  driver.quit
end

VERSIONS.each_pair do |browser, versions|
  puts "**** Browser: #{browser}"
  versions.each do |version|
    puts "** Version: #{version}"
    test_referrers(browser, version)
  end
end

