module JellyfishOdl
  class Engine < ::Rails::Engine
    isolate_namespace JellyfishOdl

    # Initializer to combine this engines static assets with the static assets of the hosting site.
    initializer 'static assets' do |app|
      app.middleware.insert_before(::ActionDispatch::Static, ::ActionDispatch::Static, "#{root}/public")
    end

    initializer 'jellyfish_odl.load_default_settings', before: :load_config_initializers do
      begin
        if ::Setting.table_exists?
          Dir[File.expand_path '../../../app/models/jellyfish_odl/setting/*.rb', __FILE__].each do |file|
            require_dependency file
          end
        end
      rescue
        # ignored
        nil
      end
    end

    initializer 'jellyfish_odl.load_product_types', before: :load_config_initializers do
      begin
        if ::ProductType.table_exists?
          Dir[File.expand_path '../../../app/models/jellyfish_odl/product_type/*.rb', __FILE__].each do |file|
            require_dependency file
          end
        end
      rescue
        # ignored
        nil
      end
    end

    initializer 'jellyfish_odl.load_registered_providers', before: :load_config_initializers do
      begin
        if ::RegisteredProvider.table_exists?
          Dir[File.expand_path '../../../app/models/jellyfish_odl/registered_provider/*', __FILE__].each do |file|
            require_dependency file
          end
        end
      rescue
        # ignored
        nil
      end
    end

    initializer 'jellyfish_odl.register_extension', after: :finisher_hook do |_app|
      Jellyfish::Extension.register 'jellyfish-odl' do
        requires_jellyfish '>= 4.0.0'

        load_scripts 'extensions/odl/components/forms/fields.config.js',
                     'extensions/odl/resources/odl-data.factory.js',
                     'extensions/odl/states/services/details/odl/router_v3/router_v3.state.js',
                     'extensions/odl/states/services/details/odl/router_v4/router_v4.state.js'

        mount_extension JellyfishOdl::Engine, at: :odl
      end
    end
  end
end
