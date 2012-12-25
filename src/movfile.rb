#encoding: utf-8

require "fileutils"
require "open3"

class MOVfile
	#出力テキストをヒアドキュメントで格納しておく
	#TODO:@@outputの外部textファイルへの移行
	@@output = <<"EOS"
----------ここからコピー----------
 <%= togo_img(day = '#{date}', file = '#{date}_0.jpg', title = 'FIGURE_TITLE') %>
ここに本文を書きます
 <%= togo_mov(mov_file = '#{filename}', img_file = '#{date}_0.jpg', x = '#{@params[:width]}', y = '#{@params[:height]}', duration = '#{duration}', editor = 'C', keyword = 'KEYWORDS', references = 'PMID,PMID') %>
 <%= netabare_start 'ここを押すと動画のスーパーが読めます。', 'button' %>
 <blockquote>
ここに@Mozk_氏謹製スクリプトの結果をコピペ
 </blockquote>
 <%= netabare_end %>
----------ここまでコピー----------

FIGURE_TITLE, 本文、KEYWORDS, PMIDを書き換えます
editorの指定 C:camtasia stadio, D:DesktopToMovie, K:Key Note, F:Final Cut, W:wink
リファレンスが無い場合はPMIDのところはそのままで可
動画を途中から再生するには settings のところを設定します。
文字だけの場合は引数2個、画像を貼る場合には引数が3個必要です。
EOS
	#サーバー上のmovie file格納場所path
	@@tv_path = "/var/www/togotv"

	#TODO:動作のテスト
	def initialize(file, filename, date)
		@file_subst = file
		@filename = filename.to_s
		raise ArgumentError, "movファイルしか指定できません" unless @filename =~ /\.mov$/
		@upload_date = setDate(date.to_s)

		#propertiesで情報を格納するHashをセット
		@params = Hash.new
		
	end

	#helper method from movie_up.rb
	private

	#set @params from system call "ffmpeg"
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
	
	#setting date
	def setDate(arg_date)
		#match to "yyyymmdd" format -> return self
	  if arg_date =~ /^\d\d\d\d\d\d\d\d/
	    return $&
		#match to "yymmdd" format -> add 20yymmdd
	  elsif arg_date[1] =~ /^\d\d\d\d\d\d/ || arg_date[0] =~ /^\d\d\d\d\d\d/
	    return "20" + $&
		#
	  else
	    t = Time.now
	    return t.strftime("%Y%m%d")
	  end
	end
end
