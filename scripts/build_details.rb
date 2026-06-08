#!/usr/bin/env ruby
# frozen_string_literal: true

require "csv"
require "cgi"
require "fileutils"

root = File.expand_path("..", __dir__)
csv_path = File.join(root, "data", "details.csv")
out_dir = File.join(root, "_generated")
out_file = File.join(out_dir, "details.html")

FileUtils.mkdir_p(out_dir)

ORCID_SVG = '<svg viewBox="0 0 24 24" fill="currentColor" width="16" height="16"><path d="M12 0C5.372 0 0 5.372 0 12s5.372 12 12 12 12-5.372 12-12S18.628 0 12 0zM7.369 4.378c.525 0 .947.431.947.947s-.422.947-.947.947a.95.95 0 0 1-.947-.947c0-.525.422-.947.947-.947zm-.722 3.038h1.444v10.041H6.647V7.416zm3.562 0h3.9c3.712 0 5.344 2.653 5.344 5.025 0 2.578-2.016 5.025-5.325 5.025h-3.919V7.416zm1.444 1.303v7.444h2.297c3.272 0 3.872-2.412 3.872-3.722 0-2.016-1.284-3.722-3.862-3.722h-2.307z"/></svg>'
ARROW_SVG = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" width="28" height="28"><path d="M5 12h14M12 5l7 7-7 7"/></svg>'

rows = CSV.read(csv_path, headers: true, encoding: "utf-8").map(&:to_h)
rows.sort_by! { |r| r.fetch("sort_order", "0").to_i }

story_rows    = rows.select { |r| r["section"] == "story" }
pub_rows      = rows.select { |r| r["section"] == "publications" }
investor_rows = rows.select { |r| r["section"] == "investor" }

html = +""

# ── My Story ──
html << "<section class=\"content-card\">\n"
html << "  <h2>My Story</h2>\n"
story_rows.each do |row|
  url    = CGI.escapeHTML(row["url"].to_s.strip)
  kicker = CGI.escapeHTML(row["kicker"].to_s.strip)
  title  = CGI.escapeHTML(row["title"].to_s.strip)
  desc   = CGI.escapeHTML(row["description"].to_s.strip)
  html << "  <a class=\"details-feature-link\" href=\"#{url}\" target=\"_blank\" rel=\"noopener\">\n"
  html << "    <div class=\"details-feature-card\">\n"
  html << "      <div class=\"details-feature-meta\">\n"
  html << "        <p class=\"project-kicker\">#{kicker}</p>\n"
  html << "        <h3>#{title}</h3>\n"
  html << "        <p>#{desc}</p>\n"
  html << "      </div>\n"
  html << "      <div class=\"details-feature-arrow\">#{ARROW_SVG}</div>\n"
  html << "    </div>\n"
  html << "  </a>\n"
end
html << "</section>\n"

# ── Publications & Research Identity ──
html << "<section class=\"content-card\">\n"
html << "  <h2>Publications &amp; Research Identity</h2>\n"
html << "  <div class=\"details-pub-grid\">\n"
pub_rows.each do |row|
  url    = CGI.escapeHTML(row["url"].to_s.strip)
  kicker = CGI.escapeHTML(row["kicker"].to_s.strip)
  title  = CGI.escapeHTML(row["title"].to_s.strip)
  desc   = CGI.escapeHTML(row["description"].to_s.strip)
  badge  = row["badge_label"].to_s.strip
  is_orcid = row["type"] == "orcid"

  if is_orcid
    badge_html = "      <span class=\"details-pub-badge orcid-badge\">#{ORCID_SVG} #{CGI.escapeHTML(badge)}</span>\n"
  elsif !badge.empty?
    badge_html = "      <span class=\"details-pub-badge\">#{CGI.escapeHTML(badge)}</span>\n"
  else
    badge_html = ""
  end

  html << "    <a class=\"details-pub-card\" href=\"#{url}\" target=\"_blank\" rel=\"noopener\">\n"
  html << "      <div class=\"project-card-header\">\n"
  html << "        <p class=\"project-kicker\">#{kicker}</p>\n"
  html << "        <h3>#{title}</h3>\n"
  html << "      </div>\n"
  html << "      <p>#{desc}</p>\n"
  html << badge_html unless badge_html.empty?
  html << "    </a>\n"
end
html << "  </div>\n"
html << "</section>\n"

# ── Investor Portfolio ──
if investor_rows.any?
  platforms = investor_rows.select { |r| r["type"] == "platform" }
  backed    = investor_rows.select { |r| r["type"] == "backed" }

  html << "<section class=\"content-card\">\n"
  html << "  <h2>Investor Portfolio</h2>\n"
  html << "  <p>Mission-aligned startup backing across sustainability, conservation technology, and community impact ventures.</p>\n"
  html << "  <div class=\"overview-grid\" style=\"margin-top:1rem\">\n"

  html << "    <article class=\"spotlight-card\">\n"
  html << "      <h3>Platform</h3>\n"
  html << "      <ul>\n"
  platforms.each do |row|
    name = CGI.escapeHTML(row["title"].to_s.strip)
    url  = row["url"].to_s.strip
    if url.empty?
      html << "        <li>#{name}</li>\n"
    else
      html << "        <li><a href=\"#{CGI.escapeHTML(url)}\" target=\"_blank\" rel=\"noopener\" style=\"color:var(--ink)\">#{name}</a></li>\n"
    end
  end
  html << "      </ul>\n"
  html << "    </article>\n"

  html << "    <article class=\"spotlight-card\">\n"
  html << "      <h3>Backed Projects</h3>\n"
  html << "      <ul>\n"
  backed.each { |row| html << "        <li>#{CGI.escapeHTML(row["title"].to_s.strip)}</li>\n" }
  html << "      </ul>\n"
  html << "    </article>\n"

  html << "  </div>\n"
  html << "</section>\n"
end

File.write(out_file, html)
