#! /usr/bin/env ruby

require 'fileutils'
require 'open3'


tv_path = "/var/www/togotv"
@params  = Hash.new


# parse movie information
def properties(info)
  info = info.split("\n")
  info.each do |line|
    if line =~ /Duration:/
      time, start, bitrate = line.chomp.split(", ")
      _, @params[:time]    = time.split(": ")
      _, @params[:start]   = start.split(": ")
      _, bitrate           = bitrate.split(": ")
      @params[:bitrate],   = bitrate.split("\s")

    elsif line =~ /Stream .+ Audio: /
      _, arate, _ = line.split(", ")
      @params[:arate] = arate.sub(/\sHz/, "")

    elsif line =~ /Stream .+ Video: /
      _, _, video     = line.chomp.split(": ")
      video           = video.split(", ")
      @params[:codec]  = video[0]
      @params[:yuv]    = video[1]
      size,           = video[2].split("\s")
      @params[:width], @params[:height] = size.split("x")
      @params[:frate], = video[3].split("\s")

    elsif line =~ /^Output/
      break
    end
  end
end


# setting date
def date
  if ARGV[1] =~ /^\d\d\d\d\d\d\d\d/ || ARGV[0] =~ /^\d\d\d\d\d\d\d\d/
    return $&
  elsif ARGV[1] =~ /^\d\d\d\d\d\d/ || ARGV[0] =~ /^\d\d\d\d\d\d/
    return "20" + $&
  else
    t = Time.now
    return t.strftime("%Y%m%d")
  end
end


#-*- main -*-
file = ARGV[0]
raise ArgumentError, "movファイルしか指定できません" unless file =~ /\.mov$/

mov_date = date()

filename = mov_date.sub(/^\d\d/, "") + file.sub(/^\d+/, "")
if file != filename
  FileUtils.install(file, filename, :mode=>0644)
end

# create thumbnail and get movie information in stderr output
pict_command = "ffmpeg -y -i #{filename} -f image2 -r 1 -t 0:0:0.001 -an #{date}_0.jpg"

stdin, stdout, stderr = Open3.popen3(pict_command)
info = stderr.read
stdin.close
stdout.close
stderr.close

stream_file = filename.sub(/\.mov/, ".streaming")

system("ln -s #{filename} #{stream_file}")
system("mv -i #{date}_0.jpg #{tv_path}/images/")
system("mv -i #{filename} #{tv_path}/movie/")
system("mv -i #{stream_file} #{tv_path}/movie/")

properties(info)

h, m, s = @params[:time].split(":")
duration = h.to_i * 60 * 60 + m.to_i * 60 + s.to_i + 1

puts "\n----------ここからコピー----------"
puts " <%= togo_img(day = '#{date}', file = '#{date}_0.jpg', title = 'FIGURE_TITLE') %>\n"
puts "ここに本文を書きます"
puts " <%= togo_mov(mov_file = '#{filename}', img_file = '#{date}_0.jpg', x = '#{@params[:width]}', y = '#{@params[:height]}', duration = '#{duration}', editor = 'C', keyword = 'KEYWORDS', references = 'PMID,PMID') %>"
puts " <%= barebare(day = '#{date}', text = 'リンクをクリックすると、その場面から動画をご覧になれます。', button_msg = 'ここを押すと動画のスーパーが読めます。', settings = [['スーパー', '秒'], ['小野△', '180'], ['画像のタイトル', '秒', '画像ファイル'], ['塩基配列の登録', '212', '20091120_4.jpg']]) %>"
puts "----------ここまでコピー----------\n\n"

puts "FIGURE_TITLE, 本文、KEYWORDS, PMIDを書き換えます"
puts "editorの指定 C:camtasia stadio, D:DesktopToMovie, K:Key Note, F:Final Cut, W:wink"
puts "リファレンスが無い場合はPMIDのところはそのままで可"
puts "動画を途中から再生するには settings のところを設定します。\n文字だけの場合は引数2個、画像を貼る場合には引数が3個必要です。\n"
puts "この組み合わせを文（画像）の数だけコピペして使います。時間の指定単位は「秒」です"

