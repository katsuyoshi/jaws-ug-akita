require 'aws-sdk'
require 'yaml'

config = YAML.load(File.read("aws.config"))

# Configuration
AWS.config(
  :access_key_id => config["ACCESS_KEY_ID"],
  :secret_access_key => config["SECRET_ACCESS_KEY"])

@s3 = AWS::S3.new


def show_all_buckets
  @s3.buckets.each do |b|
    puts b.name
  end
#  puts @s3.buckets.collect(& :name)
end

def get_bucket_by_name
  bucket = @s3.buckets['jaws-ug-akita-kito-3']
  p bucket
end

def create_bucket_if_needs
  bucket = @s3.buckets['jaws-ug-akita-kito-3-test']
  unless bucket.exists?
    bucket = @s3.buckets.create "jaws-ug-akita-kito-3-test"
  end
p bucket
  bucket
end

def delete_bucket
  bucket = @s3.buckets['jaws-ug-akita-kito-3-test']
  bucket.delete
end

def write_file
  bucket = create_bucket_if_needs
  o = bucket.objects["helloworld.txt"]
  o.write('Hello World!')
  o
end

def read_file
  o = write_file
  puts o.read
end

def upload_file
  bucket = create_bucket_if_needs
  o = bucket.objects["jaws-akita-1.jpg"]
  o.write(file: "jaws-akita-1.jpg")
  o
end

def download_file
  o = upload_file
  File.open("download.jpg", "w") do |f|
    o.read do |chunk|
      f.write chunk
    end
  end
end

def delete_bucket_and_contains_all_objects
  bucket = create_bucket_if_needs
  bucket.delete!
end

def write_file_with_server_side_encryption
  bucket = create_bucket_if_needs
  o = bucket.objects["enc-helloworld.txt"]
  o.write("Hello World!", :server_side_encryption => :aes256)
  o
end

def read_file_with_server_side_encription_by_plane
  o = write_file_with_server_side_encryption
  puts o.read
end

def create_folder
  bucket = create_bucket_if_needs
  o = bucket.objects["folder/こんにちは.txt"]
  o.write("こんにちは")
end

def prepare_versioning_file
  bucket = create_bucket_if_needs
puts "versioning of #{bucket} : #{bucket.versioning_enabled?}"
  bucket.enable_versioning
puts "versioning of #{bucket} : #{bucket.versioning_enabled?}"

  o = bucket.objects['versioning.txt']
  o.write "a"
  o.write "b"
  o.delete
  o.write "c"
  o
end

def browse_all_versions
  o = prepare_versioning_file
  o.versions.each do |obj_version|
p obj_version
    unless obj_version.delete_marker?
      puts obj_version.read
    else
      puts "- DELETE MARKER"
    end
  end
end

def latest_version
  o = prepare_versioning_file
p  o.versions.latest
end

def add_delete_rule
  bucket = create_bucket_if_needs
  bucket.lifecycle_configuration.update do
    add_rule('', :expiration_time => 365)
  end
  bucket
end


def add_transmitting_rule
  bucket = create_bucket_if_needs
  bucket.lifecycle_configuration.update do
    add_rule('backups/', :glacier_transition_time => 30)
  end
end

def append_rule
  bucket = add_delete_rule
  bucket.lifecycle_configuration.update do
    add_rule('backups/', :glacier_transition_time => 30)
  end
end

def replace_rule
  bucket = add_delete_rule
  bucket.lifecycle_configuration.replace do
    add_rule('backups/', :glacier_transition_time => 30)
  end
end



delete_bucket_and_contains_all_objects

show_all_buckets
#get_bucket_by_name
#create_bucket_if_needs
#delete_bucket
#write_file
#read_file
#upload_file
#download_file
#create_folder
#prepare_versioning_file
#browse_all_versions
#latest_version
#write_file_with_server_side_encryption
#read_file_with_server_side_encription_by_plane
#add_delete_rule
add_transmitting_rule
#append_rule
#replace_rule
#delete_bucket_and_contains_all_objects
