require 'yaml'

define :epuagent_config, :user => nil, :group => nil, :epuagent_name => nil, :epuagent_spec => nil do

  raise ArgumentError, 'user must be specified' if params[:user].nil?
  raise ArgumentError, 'group must be specified' if params[:group].nil?
  raise ArgumentError, 'epuagent_spec must be specified' if params[:epuagent_spec].nil?
  def sanitize_types(old_object)
    if old_object.is_a? ::Hash
      new_hash = {}
      old_object.each_pair do |k,v|
        new_hash[k] = sanitize_types v
      end
      new_hash
    elsif old_object.is_a? ::Array
      new_array = []
      old_object.each do |v|
        new_array.push sanitize_types v
      end
      new_array
    else
      old_object
    end
  end

  cfg_file = params[:name]
  cfg_sane = sanitize_types params[:epuagent_spec]
  cfg_yaml = YAML.dump cfg_sane

  file cfg_file do
    owner params[:user]
    group params[:group]
    content cfg_yaml
  end
end

