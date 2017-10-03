# frozen_string_literal: true

require 'scraperwiki'
require 'mechanize'
require 'json'

def get(url)
  @agent ||= Mechanize.new
  @agent.get(url)
end

def extract_deployments(page)
  selector = '.deployments__unit--major,.deployments__unit--minor'
  page.search(selector).map do |div|
    url = div.at('.deployment__link').inner_text.strip
    url += '/' if url[-1] != '/'

    {
      name: div.at('.deployment__title').inner_text,
      url: url,
      version_url: url + 'version.json'
    }
  end
end

def deployments
  return @deployments if @deployments

  puts 'Discovering deployments...'
  page = get('http://alaveteli.org/deployments/')

  @deployments = extract_deployments(page)
end

def get_version_information(deployment)
  puts "Getting version information for: #{deployment[:url]}"
  deployment[:date_checked] = Date.today

  page = get(deployment[:version_url])

  if page['content-type'] =~ /json/
    deployment.merge(JSON.parse(page.body))
  else
    deployment[:error] = "Didn't get JSON from API."
  end
rescue => e
  deployment.merge!(error: "#{e.class}: #{e.message}", date_checked: Date.today)
end

def main
  records = deployments.map { |deployment| get_version_information(deployment) }
  puts "Saving #{records.size} records"
  ScraperWiki.save_sqlite(%i[name], records)
  puts 'Done.'
end

main if $PROGRAM_NAME == __FILE__
