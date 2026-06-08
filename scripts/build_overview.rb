#!/usr/bin/env ruby
# frozen_string_literal: true

require "csv"
require "cgi"
require "fileutils"

root = File.expand_path("..", __dir__)
csv_path = File.join(root, "data", "overview.csv")
out_dir = File.join(root, "_generated")
out_file = File.join(out_dir, "overview.html")

FileUtils.mkdir_p(out_dir)

rows = CSV.read(csv_path, headers: true, encoding: "utf-8").map(&:to_h)
rows.sort_by! { |r| r.fetch("sort_order", "0").to_i }

paragraphs = rows.select { |r| r["type"] == "paragraph" }
cards = rows.select { |r| r["type"] == "card" }

html = +""

html << "<div class=\"overview-copy\">\n"
paragraphs.each do |row|
  text = CGI.escapeHTML(row["items"].to_s.strip)
  html << "  <p>#{text}</p>\n"
end
html << "</div>\n"

html << "<div class=\"overview-grid\">\n"
cards.each do |row|
  heading = CGI.escapeHTML(row["heading"].to_s.strip)
  items = row["items"].to_s.split("|").map(&:strip)
  html << "  <article class=\"spotlight-card\">\n"
  html << "    <h3>#{heading}</h3>\n"
  html << "    <ul>\n"
  items.each { |item| html << "      <li>#{CGI.escapeHTML(item)}</li>\n" }
  html << "    </ul>\n"
  html << "  </article>\n"
end
html << "</div>\n"

File.write(out_file, html)
