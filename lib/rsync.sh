#/bin/sh

# for movie and streaming
rsync -a /home/togotv/togotv_uploader/moviefile_tmp/ /var/www/togotv/movie

# for thumbnail
rsync -a /home/togotv/togotv_uploader/thumbnail_tmp/ /var/www/togotv/images
