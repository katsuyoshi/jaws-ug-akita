require 'aws-sdk'
require 'yaml'

config = YAML.load(File.read("aws.config"))

# Configuration
AWS.config(
  :access_key_id => config["ACCESS_KEY_ID"],
  :secret_access_key => config["SECRET_ACCESS_KEY"])

@s3 = AWS::S3.new


def bucket_for_screenshots
  bucket = @s3.buckets["jaws-ug-akita-kito-3-screenshots"]
  unless bucket.exists?
    bucket = @s3.buckets.create "jaws-ug-akita-kito-3-screenshots"
  end
  bucket
end


def transmit path
  bucket = bucket_for_screenshots
  name = File.basename path
  o = bucket.objects[name]
  o.write(file: path)
end


ARGV.each do |path|
  transmit path.dup.force_encoding("utf-8")
end