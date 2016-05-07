# e621pool
e621.net Pool Downloader with built-in proxy (for users from Russia)

# Install
To use this you will need: ruby, rest-client (in terminal type: `gem install rest-client`, requires ruby and may require sudo on UNIX systems)

# Usage
`ruby e621pool.rb id` where id - pool id

This will create folder with pool's name and download every single post from pool with "incremental" filenames (like 1.jpg, 2.jpg, 3.png, etc)
