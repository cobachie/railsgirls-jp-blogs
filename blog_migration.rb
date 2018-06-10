#!/usr/bin/ruby

class BlogMigration
  require 'json'
  require 'fileutils'

  class << self
    def execute(args)
      # 移行先のディレクトリパス
      dest_dir = args[0] || "../blog"

      Dir.glob("./railsgirls-jp/json/*").each do |json_file_path|
        open(json_file_path) do |io|
          hash = JSON.load(io)

          # ディレクトリを作成する
          date = hash["date"].match(/\d{4}-\d{2}-\d{2}/)
          dir_path = FileUtils.mkdir_p("#{dest_dir}/#{date}-#{hash["slug"]}", mode: 0755).first

          # 画像をコピーする
          Dir.glob("./posts/#{hash["id"]}/*").each do |fpath|
            FileUtils.cp fpath, dir_path unless File.extname(fpath) == ".html"
          end

          # index.htmlを作成する
          File.open("#{dir_path}/index.html", "w") do |f|
            f.puts(<<LAYOUT)
---
layout: post
title: #{hash["title"]}
---
LAYOUT

            f.puts("<h2>#{hash["title"]}</h2>")
            content = hash["trail"].first["content_raw"].gsub(/https:\/\/78.media.tumblr.com\/[0-9a-z]{32}\//, '')
            f.puts(content)
          end
        end
      end
    end

  end
end

BlogMigration.execute(ARGV)
