config = YAML.load_file("#{Rails.root}/config/s3.yml")
AWS_ACCESS_KEY = config["production"]["access_key_id"]
AWS_SECRET_KEY = config["production"]["secret_access_key"]
AWS_BUCKET = config["production"]["bucket"]
