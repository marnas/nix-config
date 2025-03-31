{ ... }:

{
  programs.thunderbird = {
    enable = true;
    profiles = { default_profile = { isDefault = true; }; };
  };
  accounts.email = {
    maildirBasePath = "Mail";
    accounts = {
      marnas = {
        address = "marco@santonastaso.com";
        primary = true;
        userName = "marnas";
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
        thunderbird = { enable = true; };
      };
    };
  };
}

