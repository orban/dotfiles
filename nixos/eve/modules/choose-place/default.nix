{
  services.uwsgi = {
    enable = true;
    plugins = [ "python3" ];
    instance = {
      type = "emperor";
      vassals.choose-place = {
        type = "normal";
        strict = true;
        uid = "choose-place";
        gid = "choose-place";
        enable-threads = true;
        module = "choose_place:create_app()";
        socket = "/run/uwsgi/choose-place.sock";
        chmod-socket = 664;
        pythonPackages = self: [
          (self.callPackage ./package.nix {})
        ];
      };
    };
  };

  users.users.choose-place = {
    isSystemUser = true;
    group = "choose-place";
  };
  users.groups."choose-place" = {};
  users.users.nginx.extraGroups = [ "uwsgi" ];
  systemd.services.nginx.serviceConfig.SupplementaryGroups = [ "uwsgi" ];

  services.nginx = {
    virtualHosts."choose-place.thalheim.io" = {
      useACMEHost = "thalheim.io";
      forceSSL = true;
      locations."/".extraConfig = ''
        uwsgi_pass unix:/run/uwsgi/choose-place.sock;
      '';
    };
  };

  services.netdata.httpcheck.checks.choose-place = {
    url = "https://choose-place.thalheim.io";
    regex = "Choose Place";
  };

  services.icinga2.extraConfig = ''
    apply Service "Chooseplace v4 (eve)" {
      import "eve-http4-service"
      vars.http_vhost = "hass.thalheim.io"
      vars.http_uri = "/"
      assign where host.name == "eve.thalheim.io"
    }

    apply Service "Chooseplace v6 (eve)" {
      import "eve-http6-service"
      vars.http_vhost = "hass.thalheim.io"
      vars.http_uri = "/"
      assign where host.name == "eve.thalheim.io"
    }
  '';
}