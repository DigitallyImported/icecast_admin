require 'net/http'
require 'nokogiri'

$:.unshift(File.dirname(__FILE__))
%w[ hash_from_xml admin ].each do |file|
  require "icecast/#{file}"
end