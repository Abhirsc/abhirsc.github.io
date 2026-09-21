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

rows = CSV.read(csv_path, headers: true, encoding: "utf-8").map(&:to_h)
rows.sort_by! { |row| -row.fetch("sort_order", row.fetch("year", "0")).to_i }

def normalize_image_path(path)
  value = path.to_s.strip
  return value if value.empty?
  return value if value.start_with?("http://", "https://", "/", "./", "../")
  "./#{value}"
end

def gallery_html(image_paths, id_prefix)
  slides_id = "slides-#{id_prefix}"
  html = +"<div class=\"dneg-media-gallery\" id=\"gallery-#{id_prefix}\">\n"
  html << "  <div class=\"gallery-slides\" id=\"#{slides_id}\">\n"
  image_paths.each do |img|
    html << "    <img class=\"gallery-slide\" src=\"#{CGI.escapeHTML(img)}\" alt=\"\" loading=\"lazy\" />\n"
  end
  html << "  </div>\n"
  html << "  <div class=\"gallery-controls\">\n"
  html << "    <button class=\"gallery-prev\" aria-label=\"Previous\">&#8249;</button>\n"
  image_paths.each_with_index do |_, i|
    active = i.zero? ? " is-active" : ""
    html << "    <button class=\"gallery-dot#{active}\" data-idx=\"#{i}\"></button>\n"
  end
  html << "    <button class=\"gallery-next\" aria-label=\"Next\">&#8250;</button>\n"
  html << "  </div>\n"
  html << "</div>\n"
  html
end

def detail_gallery_html(image_paths, id_prefix)
  html = +"<div class=\"detail-gallery\" id=\"dgallery-#{id_prefix}\">\n"
  html << "  <div class=\"detail-gallery-slides\" id=\"dslides-#{id_prefix}\">\n"
  image_paths.each do |img|
    html << "    <img class=\"detail-gallery-slide\" src=\"#{CGI.escapeHTML(img)}\" alt=\"\" loading=\"lazy\" style=\"object-fit:cover;width:100%;height:100%\" />\n"
  end
  html << "  </div>\n"
  html << "  <div class=\"detail-gallery-controls\">\n"
  html << "    <button class=\"gallery-prev\">&#8249;</button>\n"
  image_paths.each_with_index do |_, i|
    active = i.zero? ? " is-active" : ""
    html << "    <button class=\"gallery-dot#{active}\" data-idx=\"#{i}\"></button>\n"
  end
  html << "    <button class=\"gallery-next\">&#8250;</button>\n"
  html << "  </div>\n"
  html << "</div>\n"
  html
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
  year      = CGI.escapeHTML(row["year"].to_s)
  title     = CGI.escapeHTML(row["title"].to_s)
  period    = CGI.escapeHTML(row["period"].to_s)
  preview   = CGI.escapeHTML(row["preview"].to_s)
  detail    = CGI.escapeHTML(row["detail"].to_s).gsub("\n", "<br>\n      ")
  image     = CGI.escapeHTML(normalize_image_path(row["image"]))
  alt       = CGI.escapeHTML(row["alt"].to_s)
  link      = row["link"].to_s.strip
  detail_id = "detail-#{year}"

  raw_year = row["year"].to_s.strip

  # Auto-detect gallery using YEAR_0, YEAR_1, YEAR_2 convention
  # Uses Dir.glob to handle any extension case (.jpeg/.jpg/.png/.JPG etc.)
  auto_images = []
  (0..9).each do |i|
    matches = Dir.glob(File.join(root, "images", "#{raw_year}_#{i}.{jpeg,jpg,png,JPEG,JPG,PNG}"))
    break if matches.empty?
    auto_images << "./images/#{File.basename(matches.first)}"
  end

  if auto_images.any?
    image_paths = auto_images
  else
    images_raw = row["images"].to_s.strip
    image_paths = images_raw.empty? ? [] : images_raw.split("|").map { |p| CGI.escapeHTML(normalize_image_path(p.strip)) }
  end
  multi = image_paths.length > 1

  link_html = link.empty? ? "" : "\n          <a class=\"detail-link\" href=\"#{CGI.escapeHTML(link)}\" target=\"_blank\" rel=\"noopener\">Visit Website &#8599;</a>"

  # Card media section
  if multi
    card_media = gallery_html(image_paths, year).lines.map { |l| "          #{l}" }.join
    modal_media = detail_gallery_html(image_paths, year).lines.map { |l| "          #{l}" }.join
  else
    img_src = image_paths.first || image
    card_media = "          <div class=\"dneg-media\"><img src=\"#{img_src}\" alt=\"#{alt}\" class=\"dneg-img\" /></div>\n"
    modal_media = ""
  end

  html << <<~HTML
      <section class="dneg-year-block" id="y-#{year}" data-year="#{year}">
        <div class="dneg-divider"><span class="dneg-divider-line"></span><span class="dneg-divider-year">#{year}</span><span class="dneg-divider-line"></span></div>
        <article class="dneg-card dneg-card-clickable" data-detail="#{detail_id}" role="button" tabindex="0" aria-controls="#{detail_id}" aria-label="Open #{year} details">
  #{card_media.chomp}
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
  #{modal_media.chomp}
          <p>#{detail}</p>#{link_html}
        </div>
      </div>

  HTML
end

html << "  </main>\n"
html << "</section>\n"

File.write(out_file, html)
