#!/usr/bin/env ruby
require "net/http"

corpus_files = %w{
  http://spamassassin.apache.org/publiccorpus/20030228_easy_ham.tar.bz2
  http://spamassassin.apache.org/publiccorpus/20030228_spam.tar.bz2
  http://spamassassin.apache.org/publiccorpus/20030228_easy_ham_2.tar.bz2
  http://spamassassin.apache.org/publiccorpus/20030228_spam_2.tar.bz2
}
have_files = Dir.glob("./200*.bz2").map { |filename| Regexp.new(filename.gsub(/^\.\//, '')) }
corpus_files.delete_if do |corpus_file|
   have_files.inject(false) {|memo, have_file| memo || corpus_file =~ have_file} 
end

puts "retrieving corpus files: "

uris = corpus_files.map { |file_location| URI.parse(file_location) }
uris.each do |uri|
  puts "* " + uri.to_s
  response = Net::HTTP.start(uri.host, uri.port) do |http|
    http.get(uri.path)
  end
  File.open(uri.path.split("/").last, "w+") do |f|
    f << response.body
  end
end

puts "untarring corpus files"

Dir.glob("./200*.bz2").each do |tarball|
  puts "* " + tarball.gsub(/^\.\//, '')
  Kernel.system("tar xjf #{tarball}")
end