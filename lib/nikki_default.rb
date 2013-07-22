#encoding: utf-8

module Nikki
	def setNikki#(upload_date, filename, params)
<<EOS
----------ここからコピー----------
 <%= togo_img(day = '#{@date}', file = '#{@date}_0.jpg', title = 'FIGURE_TITLE') %>
ここに本文を書きます
 <%= togo_mov(mov_file = '#{@filename}', img_file = '#{@date}_0.jpg', x = '#{@params[:width]}', y = '#{@params[:height]}', duration = '#{@duration}', editor = 'C', keyword = 'KEYWORDS', references = 'PMID,PMID') %>
 <%= netabare_start 'ここを押すと動画のスーパーが読めます。', 'button' %>
 <blockquote>
(ここに__Hukidashi_extractor__の結果をコピペ)
 </blockquote>
 <%= netabare_end %>
----------ここまでコピー----------

FIGURE_TITLE, 本文、KEYWORDS, PMIDを書き換えます
editorの指定 C:camtasia stadio, D:DesktopToMovie, K:Keynote, F:Final Cut, W:wink
リファレンスが無い場合はPMIDのところはそのままで可
動画を途中から再生するには settings のところを設定します。
文字だけの場合は引数2個、画像を貼る場合には引数が3個必要です。
EOS
	end
end
