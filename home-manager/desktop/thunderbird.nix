{ ... }:

{
  programs.thunderbird = {
    enable = true;
    profiles = { marnas = { isDefault = true; }; };
  };
  accounts.email = {
    maildirBasePath = "Mail";
    accounts = {
      marnas = {
        address = "marco@santonastaso.com";
        primary = true;
        userName = "marco@santonastaso.com";
        flavor = "plain";
        imap = {
          host = "imap.gmail.com";
          port = 993;
          tls.enable = true;
        };
        realName = "Marco Santonastaso";
        smtp = {
          host = "smtp.gmail.com";
          port = 587;
          tls = {
            enable = true;
            useStartTls = true;
          };
        };
        thunderbird = {
          enable = true;
          settings = id: {
            "mail.server.server_${id}.delete_model" = 1;
            "mail.server.server_${id}.authMethod" = 10;
          };
        };
      };
    };
  };
}

