#encoding: utf-8

@upload_date = "121227"
f = File.open("./nikki_default.txt")
str = f.read
puts str
f.close
