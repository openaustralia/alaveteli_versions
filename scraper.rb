require "scraperwiki"
require "mechanize"

agent = Mechanize.new

puts "Discovering deployments..."
page = agent.get("http://alaveteli.org/deployments/")

deployments = page.search(".deployments__unit--major,.deployments__unit--minor").collect do |div|
  url = div.at(".deployment__link").inner_text.strip
  url += "/" if url[-1] != "/"

  {name: div.at(".deployment__title").inner_text, url: url, version_url: url + "version.json"}
end

deployments.each do |deployment|
  puts "Getting version information for #{deployment[:url]}..."
  begin
    record = JSON.parse(agent.get(deployment[:version_url]).body)
  rescue Mechanize::ResponseCodeError => e
    record = {error: e.to_s}
  end

  ScraperWiki.save_sqlite([:name], record.merge(deployment))
end

puts "Done."
