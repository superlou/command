require 'rubygems'
require 'bundler/setup'

require 'yaml'
require 'census_api'

# http://www.census.gov/prod/cen2010/doc/sf1.pdf

config = YAML.load(File.read 'config.yml')
census_client = CensusApi::Client.new(config['census_api_key'], dataset: 'SF1')
result = census_client.find('P0010001', 'PLACE')
result = result.sort_by{|p| p["P0010001"].to_i}
puts result[-20..-1]