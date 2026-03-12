require_relative "lib/boreas/application"

Rake::TaskManager.record_task_metadata = true
Rails.application.load_tasks

desc "print all tasks"
task :default do
  Rake.application.options.show_tasks = :tasks
  Rake.application.options.show_task_pattern = %r{}
  Rake.application.display_tasks_and_comments
end

desc "sync zipcode data from geonames.org (doesn't need to run often)"
task :sync_zips do
  require "zip"
  require "fileutils"

  include Boreas::RequestHelper

  Dir.mktmpdir do |dir|
    datafile = "#{dir}/data.zip"
    config_file = Rails.root.join(Boreas::GeocodingService::ZipcodeLookup::ZIP_DATA_PATH)
    zipcode_data = {}

    File.binwrite(datafile, get_url("https://download.geonames.org/export/zip/US.zip").body)

    Zip::File.open(datafile) do |zip|
      entry = zip.glob("US.txt").first
      raise "US.txt not found" unless entry

      entry.get_input_stream.read.split("\n").each do |line|
        fields = line.split("\t")

        zip, lat, long = fields[1], fields[9], fields[10]
        unless zip && lat && long
          puts "skipping invalid line: #{line.inspect}"
          next
        end

        zipcode_data[zip] = {lat: lat.to_f.round(4), long: long.to_f.round(4)}
      end
    end

    FileUtils.mkdir_p config_file.dirname
    File.write(
      config_file,
      JSON.pretty_generate(
        {
          synced_on: Date.today.to_s,
          zipcodes: zipcode_data
        }
      )
    )
  end
end
