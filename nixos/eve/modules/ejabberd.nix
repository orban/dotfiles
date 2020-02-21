{ pkgs, config, ... }: {
  services.ejabberd = {
    enable = true;
    configFile = "/etc/ejabberd.yml";
    package = pkgs.ejabberd.override {
      withPgsql = true;
      withTools = true;
    };
  };

  services.postgresql.ensureDatabases = [ "ejabberd" ];
  services.postgresql.ensureUsers = [{
    name = "ejabberd";
    ensurePermissions."DATABASE prosody" = "ALL PRIVILEGES";
  }];

  security.dhparams = {
    enable = true;
    params.nginx = {};
  };

  environment.etc."ejabberd.yml" = {
    user = "ejabberd";
    mode = "0600";
    text = ''
      loglevel: 5

      auth_method: ldap
      ldap_servers:
        - localhost
      ldap_base: "ou=users,dc=eve"
      ldap_uids:
        jabberID: "%u@%d"
      ldap_rootdn: "cn=ejabberd,ou=system,ou=users,dc=eve"
      ldap_filter: "(objectClass=jabberUser)"
      # ldap_password: ""
      include_config_file:
        - /run/keys/ejabber-ldap-password.yml

      default_db: sql
      new_sql_schema: true
      sql_type: pgsql
      sql_server: 127.0.0.1
      sql_port: 5432
      sql_username: ejabberd
      sql_database: ejabberd
      # sql_password: ejabberd
      include_config_file:
        - /run/keys/ejabber-postgres-password.yml

      hosts:
      - thalheim.io
      - anon.thalheim.io
      - higgsboson.tk
      - devkid.net
      - w01f.de

      s2s_cafile: "/etc/ssl/certs/ca-certificates.crt"

      certfiles:
      - /var/lib/acme/ejabberd-anon.thalheim.io/full.pem
      - /var/lib/acme/ejabberd-thalheim.io/full.pem
      - /var/lib/acme/ejabberd-devkid.net/full.pem
      - /var/lib/acme/ejabberd-higgsboson.tk/full.pem
      listen:
      -
        port: 5222
        ip: "::"
        module: ejabberd_c2s
        max_stanza_size: 262144
        shaper: c2s_shaper
        access: c2s
        starttls_required: true
        dhfile: "${config.security.dhparams.params.nginx.path}"
      -
        port: 5269
        ip: "::"
        module: ejabberd_s2s_in
        max_stanza_size: 524288
        dhfile: "${config.security.dhparams.params.nginx.path}"
      -
        port: 5443
        ip: "::"
        module: ejabberd_http
        tls: true
        request_handlers:
          /admin: ejabberd_web_admin
          /api: mod_http_api
          /bosh: mod_bosh
          /captcha: ejabberd_captcha
          /upload: mod_http_upload
          /ws: ejabberd_http_ws
        dhfile: "${config.security.dhparams.params.nginx.path}"
      -
        port: 5280
        ip: "::"
        module: ejabberd_http
        request_handlers:
          /admin: ejabberd_web_admin
          /.well-known/acme-challenge: ejabberd_acme
      -
        port: 1883
        ip: "::"
        module: mod_mqtt
        backlog: 1000

      s2s_use_starttls: required

      acl:
        local:
          user_regexp: ""
        loopback:
          ip:
            - 127.0.0.0/8
            - ::1/128
      access_rules:
        local:
          allow: local
        c2s:
          deny: blocked
          allow: all
        s2s:
          - allow
        announce:
          allow: admin
        configure:
          allow: admin
        muc_create:
          allow: all
        pubsub_createnode:
          allow: local
        trusted_network:
          allow: loopback
      api_permissions:
        "console commands":
          from:
            - ejabberd_ctl
          who: all
          what: "*"
        "admin access":
          who:
            access:
              allow:
                acl: loopback
                acl: admin
            oauth:
              scope: "ejabberd:admin"
              access:
                allow:
                  acl: loopback
                  acl: admin
          what:
            - "*"
            - "!stop"
            - "!start"
        "public commands":
          who:
            ip: 127.0.0.1/8
          what:
            - status
            - connected_users_number
      shaper:
        normal: 1000
        fast: 50000

      shaper_rules:
        max_user_sessions: 10
        max_user_offline_messages:
          5000: admin
          100: all
        c2s_shaper:
          none: admin
          normal: all
        s2s_shaper: fast
      modules:
        mod_adhoc: {}
        mod_admin_extra: {}
        mod_announce:
          access: announce
        mod_avatar: {}
        mod_blocking: {}
        mod_bosh: {}
        mod_caps: {}
        mod_carboncopy: {}
        mod_client_state: {}
        mod_configure: {}
        mod_disco: {}
        mod_fail2ban: {}
        mod_http_api: {}
        mod_http_upload:
          put_url: https://@HOST@:5443/upload
        mod_last: {}
        mod_mam:
          ## Mnesia is limited to 2GB, better to use an SQL backend
          ## For small servers SQLite is a good fit and is very easy
          ## to configure. Uncomment this when you have SQL configured:
          ## db_type: sql
          assume_mam_usage: true
          default: always
        mod_mqtt: {}
        mod_muc:
          host: "muc.@HOST@"
          access:
            - allow
          access_admin:
            - allow: admin
          access_create: muc_create
          access_persistent: muc_create
          access_mam:
            - allow
          default_room_options:
            mam: true
        mod_muc_admin: {}
        mod_offline:
          access_max_user_messages: max_user_offline_messages
        mod_ping: {}
        mod_privacy: {}
        mod_private: {}
        mod_proxy65:
          access: local
          max_connections: 5
        mod_pubsub:
          access_createnode: pubsub_createnode
          plugins:
            - flat
            - pep
          force_node_config:
            ## Avoid buggy clients to make their bookmarks public
            storage:bookmarks:
              access_model: whitelist
        mod_push: {}
        mod_push_keepalive: {}
        mod_register:
          ## Only accept registration requests from the "trusted"
          ## network (see access_rules section above).
          ## Think twice before enabling registration from any
          ## address. See the Jabber SPAM Manifesto for details:
          ## https://github.com/ge0rg/jabber-spam-fighting-manifesto
          ip_access: trusted_network
        mod_roster:
          versioning: true
        mod_s2s_dialback: {}
        mod_shared_roster: {}
        mod_stream_mgmt:
          resend_on_timeout: if_offline
        mod_vcard: {}
        mod_vcard_xupdate: {}
        mod_version:
          show_os: false
    '';
  };

  krops.secrets.files."ejabber-ldap-password.yml".owner = "ejabberd";
  krops.secrets.files."ejabber-postgres-password.yml".owner = "ejabberd";

  services.openldap.extraConfig = ''
    attributeType ( 1.2.752.43.9.1.1
        NAME 'jabberID'
        DESC 'The Jabber ID(s) associated with this object. Used to map a JID to an LDAP account.'
        EQUALITY caseIgnoreMatch
        SYNTAX 1.3.6.1.4.1.1466.115.121.1.15 )

    objectClass ( 1.2.752.43.9.2.1
        NAME 'jabberUser'
        DESC 'A jabber user'
        AUXILIARY
        MUST ( jabberID ) )
  '';

  services.icinga2.extraConfig = ''
    object CheckCommand "eve-xmpp_cert" {
      import "ssl_cert"
      arguments += {
        "--xmpphost" = "$ssl_cert_xmpphost$"
      }
      vars.ssl_cert_port = "5222"
      vars.ssl_cert_protocol = "xmpp"
    }

    object CheckCommand "eve-xmpp_cert4" {
      import "eve-xmpp_cert"
      vars.ssl_cert_address = "$address$"
    }

    object CheckCommand "eve-xmpp_cert6" {
      import "eve-xmpp_cert"
      vars.ssl_cert_address = "$address6$"
    }

    apply Service "JABBER C2S (eve)" {
      import "eve-service"
      check_command = "eve-xmpp_cert4"
      vars.ssl_cert_xmpphost = "thalheim.io"
      assign where host.name == "eve.thalheim.io"
    }

    apply Service "JABBER S2S (eve)" {
      import "eve-service"
      check_command = "eve-xmpp_cert4"
      vars.ssl_cert_port = "5269"
      vars.ssl_cert_protocol = "xmpp-server"
      vars.ssl_cert_xmpphost = "thalheim.io"
      assign where host.name == "eve.thalheim.io"
    }

    apply Service "JABBER C2S v6 (eve)" {
      import "eve-service"
      check_command = "eve-xmpp_cert6"
      vars.ssl_cert_xmpphost = "thalheim.io"
      assign where host.name == "eve.thalheim.io"
    }

    apply Service "JABBER S2S v6 (eve)" {
      import "eve-service"
      check_command = "eve-xmpp_cert6"
      vars.ssl_cert_port = "5269"
      vars.ssl_cert_protocol = "xmpp-server"
      vars.ssl_cert_xmpphost = "thalheim.io"
      assign where host.name == "eve.thalheim.io"
    }
  '';

  security.acme.certs = let
    cert = domain: {
      inherit domain;
      webroot = "/var/lib/acme/acme-challenge";
      postRun = "systemctl restart ejabberd.service";
      allowKeysForGroup = true;
      group = "ejabberd";
      extraDomains = {
        "upload.${domain}" = null;
        "muc.${domain}" = null;
        "pubsub.${domain}" = null;
        "proxy.${domain}" = null;
      };
    };
  in {
    "ejabberd-anon.thalheim.io" = cert "anon.thalheim.io";
    "ejabberd-devkid.net" = cert "devkid.net";
    "ejabberd-thalheim.io" = cert "thalheim.io";
    "ejabberd-higgsboson.tk" = cert "higgsboson.tk";
  };
  services.nginx.virtualHosts."anon.thalheim.io".useACMEHost = "thalheim.io";

  users.users.ejabberd.extraGroups = [ "keys" ];
  systemd.services.ejabberd.serviceConfig.SupplementaryGroups = [ "keys" ];

  services.tor.hiddenServices."jabber".map = [
    { port = "5222"; }
    { port = "5269"; }
  ];

  services.netdata.portcheck.checks = {
    xmpp-server.port = 5222;
    xmpp-client.port = 5269;
  };

  networking.firewall.allowedTCPPorts = [
    5222 # xmpp-client
    5269 # xmpp-server
    5280 # xmpp-bosh
    5443 # https
    1883 # mqtt
    # which port for proxy64?
    #6555 # xmpp-proxy65
  ];
}