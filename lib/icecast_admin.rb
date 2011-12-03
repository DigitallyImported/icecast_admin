require 'net/http'
require 'nokogiri'

$:.unshift(File.dirname(__FILE__))
%w[ version hash_from_xml admin ].each do |file|
  require "icecast_admin/#{file}"
end
