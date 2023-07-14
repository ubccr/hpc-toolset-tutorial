
src  = '/data/notebook_data'
dest = "#{ENV['HOME']}/jupyter_notebook_data"

unless Dir.exists?(dest)
  FileUtils.copy_entry src, dest
end
