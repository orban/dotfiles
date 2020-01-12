{
  services.teamspeak3.enable = true;
  services.netdata.portcheck.checks = {
    teamspeak-ft.port = 30033;
    teamspeak-sq.port = 10011;
  };

  networking.firewall.allowedTCPPorts = [
    30033 # ts3_ft
    10011 # ts3_sq
  ];

  networking.firewall.allowedUDPPorts = [
    9987  # ts3_devkid
    22222 # ts3_martijn
    5037  # ts3_martin
    9000  # ts3_putzy
  ];
  services.icinga2.extraConfig = ''
    apply Service "Teamspeak FT v4 (eve)" {
      import "eve-tcp4-service"
      vars.tcp_port = 30033
      assign where host.name == "eve.thalheim.io"
    }

    apply Service "Teamspeak FT v6 (eve)" {
      import "eve-tcp6-service"
      vars.tcp_port = 30033
      assign where host.name == "eve.thalheim.io"
    }

    apply Service "Teamspeak SQ v4 (eve)" {
      import "eve-tcp4-service"
      vars.tcp_port = 10011
      assign where host.name == "eve.thalheim.io"
    }

    apply Service "Teamspeak SQ v6 (eve)" {
      import "eve-tcp6-service"
      vars.tcp_port = 10011
      assign where host.name == "eve.thalheim.io"
    }
  '';

}
