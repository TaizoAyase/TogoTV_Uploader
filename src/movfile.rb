#encoding: utf-8

require "fileutils"
require "open3"

class MOVfile
	#出力テキストをヒアドキュメントで格納しておく
	#TODO:@@outputの外部textファイルへの移行と変数・メソッドの改名
=begin
	@@output = <<"EOS"
----------ここからコピー----------
 <%= togo_img(day = '#{@upload_date}', file = '#{@upload_date}_0.jpg', title = 'FIGURE_TITLE') %>
ここに本文を書きます
 <%= togo_mov(mov_file = '#{@filename}', img_file = '#{@upload_date}_0.jpg', x = '#{@params[:width]}', y = '#{@params[:height]}', duration = '#{duration}', editor = 'C', keyword = 'KEYWORDS', references = 'PMID,PMID') %>
 <%= netabare_start 'ここを押すと動画のスーパーが読めます。', 'button' %>
 <blockquote>
(ここに@Mozk_氏謹製スクリプトの結果をコピペ)
 </blockquote>
 <%= netabare_end %>
----------ここまでコピー----------

FIGURE_TITLE, 本文、KEYWORDS, PMIDを書き換えます
editorの指定 C:camtasia stadio, D:DesktopToMovie, K:Key Note, F:Final Cut, W:wink
リファレンスが無い場合はPMIDのところはそのままで可
動画を途中から再生するには settings のところを設定します。
文字だけの場合は引数2個、画像を貼る場合には引数が3個必要です。
EOS
=end

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

	#helper methods from movie_up.rb
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
		match_yyyymmdd = arg_date =~ /^\d{8}/ || @filename =~ /^\d{8}/
		match_yymmdd = arg_date =~ /^\d{6}/ || @filename =~ /^\d{6}/
		#match to "yyyymmdd" format -> return self
		if match_yyyymmdd
	    return $&
		#match to "yymmdd" format -> return 20yymmdd
		elsif match_yymmdd
	    return "20" + $&
		else
	    t = Time.now
	    return t.strftime("%Y%m%d")
		end
	end

	#setting duration
	def setDuration
		h, m, s = @params[:time].split(":")
		@duration = h.to_i * 60 * 60 + 
								m.to_i * 60 + 
								s.to_i + 1
	end
end
