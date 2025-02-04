
src  = '/data/notebook_data'
dest = "#{ENV['HOME']}/jupyter_notebook_data"

unless Dir.exist?(dest)
  FileUtils.copy_entry src, dest
end
