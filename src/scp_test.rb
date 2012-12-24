#encoding: utf-8

require "net/ssh"
require "net/scp"

=begin
puts Dir.pwd
File.open("./hoge.txt") do |f|
	puts f.read
end
=end

#=begin
Net::SSH.start("togotv.dbcls.jp", "togotv", :password => "lifesciencedb") do |ssh|
	puts ssh.exec! "pwd"
	puts ssh.exec! "cd /home"
	puts ssh.exec! "pwd"
	puts ssh.exec! "cd ~"
	puts ssh.exec! "pwd"
end
#=end

=begin
Net::SCP.start("togotv.dbcls.jp", "togotv", {:password => "lifesciencedb", :compression => true}) do |scp|
	#転送先のpathはFull pathでないとだめ？
	#"~/"は展開してくれないようだ
	scp.upload!("./hoge.txt", "/home/togotv")

	#これは正常に動作
	scp.download!("test.txt", "./")
end
=end
