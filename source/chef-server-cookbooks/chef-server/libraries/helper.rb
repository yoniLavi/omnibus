class OmnibusHelper
  def self.should_notify?(service_name)
    File.symlink?("/opt/opscode/service/#{service_name}")
  end
end
