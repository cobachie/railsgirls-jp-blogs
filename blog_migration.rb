#!/usr/bin/ruby

class BlogMigration
  require 'json'
  require 'fileutils'

  class << self
    def execute(args)
      # 移行先のアプリケーションROOT
      dest_root = args[0] || "."
      blog_dir = "#{dest_root}/_blog"
      images_dir = "#{dest_root}/images/blog"

      # 画像をコピー
      Dir.glob("./railsgirls-jp/media/*").each do |image_path|
        FileUtils.cp image_path, images_dir
      end

      # htmlを作成
      Dir.glob("./railsgirls-jp/json/*").each do |json_file_path|
        open(json_file_path) do |io|
          hash = JSON.load(io)

          date = hash["date"].match(/\d{4}-\d{2}-\d{2}/)
          file_name = "#{blog_dir}/#{date}-#{hash["slug"]}.html"
          File.open(file_name, "w") do |f|
            f.puts(<<EOS)
---
layout: post
title: #{hash["title"]}
date: #{hash["date"]}
---
EOS

            f.puts("<h2>#{hash["title"]}</h2>")
            content = hash["trail"].first["content_raw"].gsub(/https:\/\/78.media.tumblr.com\/[0-9a-z]{32}/, '/images/blog')
            f.puts(content)
          end
        end
      end
    end

  end
end

BlogMigration.execute(ARGV)
