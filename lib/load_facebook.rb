# load Facebook info for this environment
FACEBOOK_INFO = YAML.load_file(File.join(File.dirname(__FILE__), "..", "config", "facebook.yml"))[ENV["RACK_ENV"]]

