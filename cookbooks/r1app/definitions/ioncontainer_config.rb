define :ioncontainer_config, :user => nil, :group => nil, :ioncontainer_name => nil, :ioncontainer_spec => nil do
  
  raise ArgumentError, 'user must be specified' if params[:user].nil?
  raise ArgumentError, 'group must be specified' if params[:group].nil?
  raise ArgumentError, 'ioncontainer_name must be specified' if params[:ioncontainer_name].nil?
  raise ArgumentError, 'ioncontainer_spec must be specified' if params[:ioncontainer_spec].nil?
  
  # The following excruciating config work should be a Ruby block somehow
  bash "create rel file preamble" do
    user "#{params[:user]}"
    group "#{params[:group]}"
    code <<-EOH
    echo -e "# Autogenerated\n{\n  'type':'release'," > #{params[:name]}
    echo "  'name':'#{params[:ioncontainer_name]}'," >> #{params[:name]}
    echo "  'version':'0.2'," >> #{params[:name]}
    echo "  'apps':[" >> #{params[:name]}
    chmod 600 #{params[:name]}
    EOH
  end
  
  # The impedance mismatch between JSON and Python rears its head 
  params[:ioncontainer_spec].each do |app_name, app_config|
    
    ruby_block "build-appconf1" do
      block do
        one_app = "\n    {'name':'#{app_config[:name]}', "
        one_app << "\n     'version':'#{app_config[:version]}', "
        if app_config.include? :mult and app_config[:mult]
          one_app << "\n     'mult':True, "
        end
        one_app << "\n     'args':{"
        app_config[:args].each do |key, value|
          one_app << "'#{key}':'#{value}', "
        end
        one_app << "},\n     'config':{"
        File.open(params[:name], 'a') {|f| f.write(one_app) }
      end
    end
    app_config[:config].each do |modname, keyvalue_dict|
      ruby_block "start-mod" do
        block do
          one_mod_start = "\n               '#{modname}':{ "
          File.open(params[:name], 'a') {|f| f.write(one_mod_start) }
        end
      end
      keyvalue_dict.each do |l_key, l_value|
        ruby_block "build-mod-kv" do
          block do
            kv_line = "     '#{l_key}': '" + l_value.to_s + "',\n"
            File.open(params[:name], 'a') {|f| f.write(kv_line) }
          end
        end
      end
      ruby_block "end-mod" do
        block do
          one_mod_end = " },\n"
          File.open(params[:name], 'a') {|f| f.write(one_mod_end) }
        end
      end
    end
    
    ruby_block "end-app" do
      block do
        app_end = "}},\n"
        File.open(params[:name], 'a') {|f| f.write(app_end) }
      end
    end
  end
  
  ruby_block "finish-file" do
    block do
      file_end = "  ]\n}\n"
      File.open(params[:name], 'a') {|f| f.write(file_end) }
    end
  end
end