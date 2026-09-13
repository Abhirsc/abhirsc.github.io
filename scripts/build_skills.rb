#!/usr/bin/env ruby
# frozen_string_literal: true

require "csv"
require "cgi"
require "fileutils"

root = File.expand_path("..", __dir__)
csv_path = File.join(root, "data", "skills.csv")
out_dir = File.join(root, "_generated")
out_file = File.join(out_dir, "skills.html")

FileUtils.mkdir_p(out_dir)

rows = CSV.read(csv_path, headers: true, encoding: "utf-8").map(&:to_h)

groups = {}
rows.each do |row|
  cat = row["category"].to_s.strip
  skill = row["skill"].to_s.strip
  next if cat.empty? || skill.empty?
  groups[cat] ||= []
  groups[cat] << skill
end

html = +"<div class=\"skills-groups\">\n"
groups.each do |category, skills|
  html << "  <div class=\"skills-group\">\n"
  html << "    <p class=\"skills-group-label\">#{CGI.escapeHTML(category)}</p>\n"
  html << "    <div class=\"skills-cloud\">\n"
  skills.each do |skill|
    html << "      <span class=\"skill-pill\">#{CGI.escapeHTML(skill)}</span>\n"
  end
  html << "    </div>\n"
  html << "  </div>\n"
end
html << "</div>\n"

File.write(out_file, html)
