{ config, lib, pkgs, ... }:

let
  urls = [
    "eve"
    #"rock"
    "matchbox"
  ];
in
{
  services.telegraf.extraConfig.inputs = {
    ping =
      (map
        (url: {
          method = "native";
          urls = [ url ];
          tags.type = "mobile";
          tags.host = url;
          tags.org = "private";
          count = 5;
        })
        [ "turingmachine.r" "herbert.r" ]) ++
      (map
        (url: {
          method = "native";
          urls = [ "6.${url}.r" ];
          ipv6 = true;
          tags.host = url;
          tags.org = "private";
        })
        urls);
    net_response =
      (map
        (host: {
          protocol = "tcp";
          address = "${host}.r:22";
          tags.host = host;
          tags.org = "private";
          send = "SSH-2.0-Telegraf";
          expect = "SSH-2.0";
          timeout = "10s";
        })
        urls) ++
      (map
        (port: {
          protocol = "tcp";
          tags.host = "eve";
          tags.org = "private";
          address = "devkid.net:${toString port}";
        }) [
        30033 # ts3_ft
        10011 # ts3_sq
      ]) ++ [
        {
          # imap
          protocol = "tcp";
          tags.host = "eve";
          tags.org = "private";
          address = "imap.thalheim.io:143";
        }
        {
          # imaps
          protocol = "tcp";
          tags.host = "eve";
          tags.org = "private";
          address = "imap.thalheim.io:993";
        }
        {
          # sieve
          protocol = "tcp";
          tags.host = "eve";
          tags.org = "private";
          address = "imap.thalheim.io:4190";
        }
        {
          # xmpp-client
          protocol = "tcp";
          tags.host = "eve";
          tags.org = "private";
          address = "jabber.thalheim.io:5222";
        }
        {
          # xmpp-server
          protocol = "tcp";
          tags.host = "eve";
          tags.org = "private";
          address = "jabber.thalheim.io:5269";
        }
        {
          # openldap
          protocol = "tcp";
          tags.host = "eve";
          tags.org = "private";
          address = "eve.r:389";
        }
        {
          # openldap
          protocol = "tcp";
          tags.host = "eva";
          address = "eva.r:389";
        }
        {
          # postfix: smtp
          protocol = "tcp";
          # amazon does block port 25
          tags.host = "eve";
          tags.org = "private";
          address = "eve.r:25";
        }
        {
          # postfix: submission
          protocol = "tcp";
          tags.host = "eve";
          tags.org = "private";
          address = "mail.thalheim.io:587";
        }
        {
          # postfix: smtps
          protocol = "tcp";
          tags.host = "eve";
          tags.org = "private";
          address = "mail.thalheim.io:465";
        }
        {
          protocol = "tcp";
          address = "eve.thalheim.io:22";
          tags.host = "eve";
          tags.org = "private";
          send = "SSH-2.0-Telegraf";
          expect = "SSH-2.0";
        }
      ];

    http_response = [
      {
        urls = [ "https://www.wikipedia.org/" ];
        http_proxy = ''https://telegraf%40thalheim.io:''${LDAP_PASSWORD}@devkid.net:8889'';
        tags.host = "eve";
        tags.org = "private";
        response_string_match = "wikipedia.org";
      }
      {
        urls = [ "https://adminer.thalheim.io/" ];
        tags.host = "eve";
        tags.org = "private";
        response_string_match = "Login";
      }
      {
        urls = [ "https://mail.thalheim.io" ];
        tags.host = "eve";
        tags.org = "private";
        response_string_match = "javascript";
      }
      {
        urls = [ "https://ist.devkid.net/wiki/Hauptseite" ];
        tags.host = "eve";
        tags.org = "private";
        response_string_match = "Informationssystemtechnik";
      }
      {
        urls = [ "https://rss.devkid.net" ];
        tags.org = "private";
        tags.host = "eve";
      }
      {
        urls = [ "https://rspamd.thalheim.io" ];
        tags.host = "eve";
        tags.org = "private";
        response_string_match = "Rspamd";
      }
      {
        urls = [ "https://glowing-bear.thalheim.io" ];
        tags.host = "eve";
        tags.org = "private";
        response_string_match = "Glowing";
      }
      {
        urls = [ "https://grafana.thalheim.io/login" ];
        tags.host = "eve";
        tags.org = "private";
        response_string_match = "Grafana";
      }
      {
        tags.host = "eve";
        tags.org = "private";
        urls = [ "https://dl.thalheim.io/OtNjoZOUnEn3H6LJZ1qcIw/test" ];
      }
      {
        urls = [ "https://syncthing.thalheim.io" ];
        username = "syncthing";
        password = "$SYNCTHING_PASSWORD";
        tags.host = "eve";
        tags.org = "private";
        response_string_match = "Syncthing";
      }
      {
        urls = [ "https://git.thalheim.io" ];
        tags.host = "eve";
        tags.org = "private";
        response_string_match = "Gitea";
      }
      {
        urls = [ "https://bitwarden.thalheim.io/alive" ];
        tags.host = "eve";
        tags.org = "private";
        response_string_match = ''"20'';
      }
      {
        urls = [ "https://thalheim.io" ];
        tags.host = "eve";
        tags.org = "private";
        response_string_match = "Jörg Thalheim";
      }
      {
        urls = [ "http://tts.r" ];
        tags.host = "eve";
        tags.org = "private";
        response_string_match = "TTS";
      }
      {
        urls = [ "http://loki.r/ready" ];
        tags.host = "rock";
        tags.org = "private";
        response_string_match = "ready";
      }
      {
        urls = [
          "https://cloud.thalheim.io/login"
          "https://pim.devkid.net/login"
        ];
        tags.host = "eve";
        tags.org = "private";
        response_string_match = "Nextcloud";
      }
      {
        urls = [ "https://influxdb.thalheim.io:8086/ping" ];
        tags.org = "private";
        tags.host = "eve";
      }
    ];

    dns_query = {
      servers = [
        "ns2.thalheim.io"
        "ns2.he.net"
        "ns3.he.net"
        "ns4.he.net"
        "ns5.he.net"
      ];
      domains = [
        "lekwati.com"
        "thalheim.io"
      ];
      tags.host = "eve";
      tags.org = "private";
      network = "tcp";
      record_type = "A";
    };

    exec = [{
      ## Commands array
      commands =
        let
          kdigHealth = pkgs.writeScript "kdig-health" ''
            #!${pkgs.runtimeShell}
            proto=$1
            if ${pkgs.knot-dns}/bin/kdig +short "+$proto" example.com A @dns.thalheim.io >/dev/null; then
              result=0
            else
              result=1
            fi
            echo secure_dns,protocol=$proto state=$result
          '';
        in
        [
          "${kdigHealth} https"
          "${kdigHealth} tls"
        ];
      data_format = "influx";
      tags.host = "eve";
      tags.org = "private";
    }];

    x509_cert = [
      {
        sources = [
          # nginx
          "https://devkid.net:443"
          "https://thalheim.io:443"
          "https://tts.r:443"
          "https://loki.r:443"
          "https://prometheus.r:443"
          "https://alertmanager.r:443"
          # squid
          "https://devkid.net:8889"
          # dovecot
          "tcp://imap.thalheim.io:993"
          "tcp://imap.devkid.net:993"
          #  postfix
          "tcp://mail.thalheim.io:465"
        ];
        tags.host = "eve";
        tags.org = "private";
      }
      {
        sources = [
          # nginx
          "https://prometheus.thalheim.io:443"
          "https://alertmanager.thalheim.io:443"
        ];
        tags.host = "eva";
        tags.org = "private";
      }
    ];
  };
}
