#!/usr/bin/env ruby
# frozen_string_literal: true

require "csv"
require "cgi"
require "fileutils"

root = File.expand_path("..", __dir__)
csv_path = File.join(root, "data", "impact_pillars.csv")
out_dir = File.join(root, "_generated")
out_file = File.join(out_dir, "impact_pillars.html")

FileUtils.mkdir_p(out_dir)

rows = CSV.read(csv_path, headers: true, encoding: "utf-8").map(&:to_h)
rows.sort_by! { |r| r.fetch("sort_order", "0").to_i }

html = +""

rows.each do |row|
  type = row["type"].to_s.strip
  body = CGI.escapeHTML(row["body"].to_s.strip)

  if type == "intro"
    html << "<p style=\"font-size:1.05rem;line-height:1.72;margin:0 0 1rem;max-width:760px\">#{body}</p>\n"
  elsif type == "pillar"
    title = CGI.escapeHTML(row["title"].to_s.strip)
    html << "<div class=\"impact-pillar\">\n"
    html << "  <p class=\"impact-pillar-title\">#{title}</p>\n"
    html << "  <p>#{body}</p>\n"
    html << "</div>\n"
  end
end

# Wrap pillars in grid (everything except first intro paragraph)
pillar_rows = rows.select { |r| r["type"].to_s.strip == "pillar" }
intro_rows  = rows.select { |r| r["type"].to_s.strip == "intro" }

html = +""

intro_rows.each do |row|
  body = CGI.escapeHTML(row["body"].to_s.strip)
  html << "<p style=\"font-size:1.05rem;line-height:1.72;margin:0 0 1rem;max-width:760px\">#{body}</p>\n"
end

unless pillar_rows.empty?
  html << "<div class=\"impact-pillars\">\n"
  pillar_rows.each do |row|
    title = CGI.escapeHTML(row["title"].to_s.strip)
    body  = CGI.escapeHTML(row["body"].to_s.strip)
    html << "  <div class=\"impact-pillar\">\n"
    html << "    <p class=\"impact-pillar-title\">#{title}</p>\n"
    html << "    <p>#{body}</p>\n"
    html << "  </div>\n"
  end
  html << "</div>\n"
end

File.write(out_file, html)
