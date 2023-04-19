Rails.application.config.after_initialize do
  OodFilesApp.candidate_favorite_paths.tap do |paths|
    # add User project space directory
    paths << FavoritePath.new("/etc/ood/config", title: "OOD Config")
  end
end