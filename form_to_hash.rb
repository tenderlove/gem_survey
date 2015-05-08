require 'nokogiri'
require 'net/http'
require 'pp'

uri = URI.parse 'https://docs.google.com/forms/d/1BlBZY8yZlny1Js6UOVnBos2Qf9pROUgoXN42mgkhLbk/viewform'
response = Net::HTTP.get_response(uri)
doc = Nokogiri.XML response.body
form_data = doc.css('div.ss-form-entry').each_with_object({}) do |entry, obj|
  name = entry.at_css('input')['name']
  const = entry.at_css('div.ss-q-title').children.first.text.chomp
  obj[name] = const
end

pp form_data
