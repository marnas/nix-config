{ lib, buildGoModule, fetchFromGitHub }:
buildGoModule rec {
  pname = "conduktor-ctl";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "conduktor";
    repo = "ctl";
    rev = "refs/tags/v${version}";
    hash = "sha256-1keo9nL+vC8jYSvKkEyj2ridhKyu7ekyTJTk0/7gTHY=";
  };

  vendorHash = "sha256-HoIRw72Rxonwozqqz8z+YtZDKIJ6k5pqjf/EQFkhDik=";

  postInstall = ''
    mv $out/bin/ctl $out/bin/conduktor
  '';

  meta = {
    description =
      "Conduktor CLI to perform operations directly from your command line or a CI/CD pipeline";
    homepage = "https://github.com/conduktor/ctl";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ marnas ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}

