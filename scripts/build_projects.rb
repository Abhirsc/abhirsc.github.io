#!/usr/bin/env ruby
# frozen_string_literal: true

require "csv"
require "cgi"
require "fileutils"

root = File.expand_path("..", __dir__)
csv_path = File.join(root, "data", "projects.csv")
out_dir = File.join(root, "_generated")
out_file = File.join(out_dir, "projects.html")

FileUtils.mkdir_p(out_dir)

rows = CSV.read(csv_path, headers: true, encoding: "utf-8").map(&:to_h)
rows.sort_by! { |r| r.fetch("sort_order", "0").to_i }

categories = rows.map { |r| r["category"].to_s.strip }.uniq

html = +""

categories.each_with_index do |cat, idx|
  active = idx.zero? ? " is-active" : ""
  html << "<div class=\"subtab-panel#{active}\" data-subpanel=\"#{CGI.escapeHTML(cat)}\">\n"
  html << "  <div class=\"project-grid\">\n"

  rows.select { |r| r["category"].to_s.strip == cat }.each do |row|
    kicker = CGI.escapeHTML(row["kicker"].to_s.strip)
    title  = CGI.escapeHTML(row["title"].to_s.strip)
    desc   = CGI.escapeHTML(row["description"].to_s.strip)
    tags   = row["tags"].to_s.split("|").map(&:strip).reject(&:empty?)
    l1l    = row["link1_label"].to_s.strip
    l1u    = row["link1_url"].to_s.strip
    l2l    = row["link2_label"].to_s.strip
    l2u    = row["link2_url"].to_s.strip

    html << "    <article class=\"project-card\">\n"
    html << "      <div class=\"project-card-header\">\n"
    html << "        <p class=\"project-kicker\">#{kicker}</p>\n"
    html << "        <h3>#{title}</h3>\n"
    html << "      </div>\n"
    html << "      <p class=\"project-desc\">#{desc}</p>\n"

    unless tags.empty?
      html << "      <ul class=\"project-tags\">\n"
      tags.each { |tag| html << "        <li>#{CGI.escapeHTML(tag)}</li>\n" }
      html << "      </ul>\n"
    end

    html << "      <div class=\"project-links\">\n"
    unless l1l.empty? || l1u.empty?
      html << "        <a class=\"project-link\" href=\"#{CGI.escapeHTML(l1u)}\" target=\"_blank\" rel=\"noopener\">#{CGI.escapeHTML(l1l)}</a>\n"
    end
    unless l2l.empty? || l2u.empty?
      html << "        <a class=\"project-link project-link-outline\" href=\"#{CGI.escapeHTML(l2u)}\" target=\"_blank\" rel=\"noopener\">#{CGI.escapeHTML(l2l)}</a>\n"
    end
    html << "      </div>\n"
    html << "    </article>\n"
  end

  html << "  </div>\n"
  html << "</div>\n"
end

File.write(out_file, html)
