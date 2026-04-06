#!/usr/bin/env ruby
# frozen_string_literal: true

require "csv"
require "cgi"
require "fileutils"

root = File.expand_path("..", __dir__)
csv_path = File.join(root, "data", "timeline.csv")
out_dir = File.join(root, "_generated")
out_file = File.join(out_dir, "timeline.html")

FileUtils.mkdir_p(out_dir)

rows = CSV.read(csv_path, headers: true).map(&:to_h)
rows.sort_by! { |row| -row.fetch("sort_order", row.fetch("year", "0")).to_i }

def normalize_image_path(path)
  value = path.to_s.strip
  return value if value.empty?
  return value if value.start_with?("http://", "https://", "/", "./", "../")

  "./#{value}"
end

html = +""
html << "<section class=\"dneg-wrap\" aria-label=\"Timeline Resume\">\n"
html << "  <aside class=\"dneg-rail\" aria-label=\"Timeline years\">\n"

rows.each_with_index do |row, index|
  year = CGI.escapeHTML(row["year"].to_s)
  active = index.zero? ? " is-active" : ""
  html << "    <button class=\"dneg-year#{active}\" data-target=\"y-#{year}\" type=\"button\">#{year}</button>\n"
end

html << "  </aside>\n"
html << "  <main class=\"dneg-content\" id=\"timeline\">\n"

rows.each do |row|
  year = CGI.escapeHTML(row["year"].to_s)
  title = CGI.escapeHTML(row["title"].to_s)
  period = CGI.escapeHTML(row["period"].to_s)
  preview = CGI.escapeHTML(row["preview"].to_s)
  detail = CGI.escapeHTML(row["detail"].to_s).gsub("\n", "<br>\n      ")
  image = CGI.escapeHTML(normalize_image_path(row["image"]))
  alt = CGI.escapeHTML(row["alt"].to_s)
  detail_id = "detail-#{year}"

  html << <<~HTML
      <section class="dneg-year-block" id="y-#{year}" data-year="#{year}">
        <div class="dneg-divider"><span class="dneg-divider-line"></span><span class="dneg-divider-year">#{year}</span><span class="dneg-divider-line"></span></div>
        <article class="dneg-card dneg-card-clickable" data-detail="#{detail_id}" role="button" tabindex="0" aria-controls="#{detail_id}" aria-label="Open #{year} details">
          <div class="dneg-media"><img src="#{image}" alt="#{alt}" class="dneg-img" /></div>
          <div class="dneg-copy">
            <h3>#{title}</h3>
            <p class="dneg-kicker">#{period}</p>
            <p>#{preview}</p>
          </div>
        </article>
      </section>

      <div id="#{detail_id}" class="detail-modal" onclick="closeDetailModal('#{detail_id}', event)">
        <div class="detail-panel" role="dialog" aria-modal="true" aria-labelledby="detail-title-#{year}">
          <button class="detail-close" type="button" onclick="forceCloseDetailModal('#{detail_id}')" aria-label="Close details">&times;</button>
          <h3 id="detail-title-#{year}">#{title}</h3>
          <p class="dneg-kicker">#{period}</p>
          <p>#{detail}</p>
        </div>
      </div>

  HTML
end

html << "  </main>\n"
html << "</section>\n"

File.write(out_file, html)
