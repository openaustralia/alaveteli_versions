# frozen_string_literal: true

require 'scraperwiki'
require 'mechanize'
require 'json'

agent = Mechanize.new

puts 'Discovering deployments...'
page = agent.get('http://alaveteli.org/deployments/')

selector = '.deployments__unit--major,.deployments__unit--minor'
deployments = page.search(selector).map do |div|
  url = div.at('.deployment__link').inner_text.strip
  url += '/' if url[-1] != '/'

  {
    name: div.at('.deployment__title').inner_text,
    url: url,
    version_url: url + 'version.json'
  }
end

deployments.each do |deployment|
  puts "Getting version information for #{deployment[:url]}..."

  begin
    page = agent.get(deployment[:version_url])

    record = if page['content-type'] =~ /json/
               JSON.parse(page.body)
             else
               { error: %(Didn't get JSON from API.) }
             end
  rescue => e
    record = { error: "#{e.class}: #{e.message}" }
  end

  record.merge!(deployment)[:date_checked] = Date.today

  ScraperWiki.save_sqlite([:name], record)
end

puts 'Done.'
