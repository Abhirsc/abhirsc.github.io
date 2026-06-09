#!/usr/bin/env ruby
# frozen_string_literal: true

require "cgi"
require "fileutils"

root     = File.expand_path("..", __dir__)
idea_dir = File.join(root, "idea-pages")
out_dir  = File.join(root, "_generated")
out_file = File.join(out_dir, "idea-blogs.html")

FileUtils.mkdir_p([idea_dir, out_dir])

pages = Dir.glob(File.join(idea_dir, "page*.txt")).sort

html = +"<div class=\"blog-list\">\n"

if pages.empty?
  html << "  <article class=\"blog-entry\"><h3>No idea pages yet</h3><p>Add <code>idea-pages/page1.txt</code> and render to publish it here.</p></article>\n"
else
  pages.each do |path|
    base   = File.basename(path)
    lines  = File.readlines(path, encoding: "utf-8").map(&:rstrip).reject(&:empty?)
    title  = lines.first.to_s.sub(/^#+\s*/, "").strip
    title  = base if title.empty?
    excerpt = lines.drop(1).first(3).join(" ").strip
    excerpt = "Open the file to add your content." if excerpt.empty?

    html << "  <article class=\"blog-entry\">\n"
    html << "    <h3>#{CGI.escapeHTML(title)}</h3>\n"
    html << "    <p>#{CGI.escapeHTML(excerpt)}</p>\n"
    html << "    <a href=\"idea-pages/#{CGI.escapeHTML(base)}\" target=\"_blank\" rel=\"noopener\">Open #{CGI.escapeHTML(base)}</a>\n"
    html << "  </article>\n"
  end
end

html << "</div>\n"

File.write(out_file, html)
