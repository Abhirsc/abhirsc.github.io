#!/usr/bin/env ruby
# frozen_string_literal: true

require "csv"
require "cgi"
require "fileutils"

root = File.expand_path("..", __dir__)
csv_path = File.join(root, "data", "impact_stats.csv")
out_dir = File.join(root, "_generated")
out_file = File.join(out_dir, "impact_stats.html")

FileUtils.mkdir_p(out_dir)

rows = CSV.read(csv_path, headers: true, encoding: "utf-8").map(&:to_h)
rows.sort_by! { |r| r.fetch("sort_order", "0").to_i }

html = +"<div class=\"impact-stats-grid\">\n"

rows.each do |row|
  num       = CGI.escapeHTML(row["num"].to_s.strip)
  unit      = CGI.escapeHTML(row["unit"].to_s.strip)
  label     = CGI.escapeHTML(row["label"].to_s.strip)
  context   = CGI.escapeHTML(row["context"].to_s.strip)
  fill      = row["fill"].to_s.strip.to_i
  total     = row["total"].to_s.strip.to_i
  overflow  = row["overflow"].to_s.strip.downcase == "true"
  num_style = row["num_style"].to_s.strip

  style_attr = num_style.empty? ? "" : " style=\"#{CGI.escapeHTML(num_style)}\""

  html << "  <div class=\"istat\">\n"
  html << "    <div class=\"istat-top\">\n"
  html << "      <span class=\"istat-num\"#{style_attr}>#{num}</span>\n"
  html << "      <span class=\"istat-unit\">#{unit}</span>\n" unless unit.empty?
  html << "    </div>\n"
  html << "    <div class=\"istat-label\">#{label}</div>\n"
  html << "    <div class=\"istat-context\">#{context}</div>\n"

  overflow_attr = overflow ? " data-overflow=\"true\"" : ""
  html << "    <div class=\"dot-grid\" data-fill=\"#{fill}\" data-total=\"#{total}\"#{overflow_attr}></div>\n"

  html << "  </div>\n"
end

html << "</div>\n"

File.write(out_file, html)
