
src  = '/data/notebook_data'
dest = "#{ENV['HOME']}/jupyter_notebook_data"

unless Dir.exists?(dest)
  FileUtils.copy_entry src, dest
end

load_scl = <<EOF

if [[ ${HOSTNAME%%.*} == ondemand ]]
then
  source scl_source enable ondemand
fi

EOF

profile = File.join(Dir.home, ".bash_profile")
if File.file?(profile) && File.readable?(profile) && File.writable?(profile) && ! File.read(profile).include?("source scl_source enable ondemand")
  File.open(profile, "a") {|f| f.write(load_scl) }
end
