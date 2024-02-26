{ tmuxPlugins
, fetchFromGitHub
, lib
}:
tmuxPlugins.mkTmuxPlugin
{
  pluginName = "tilish-colemak";
  version = "unstable-2023-05-12";
  src = fetchFromGitHub {
    owner = "marnas";
    repo = "tmux-tilish-colemak";
    rev = "d81c007f29aa3d81f1381eda58dc1fd0524d55f1";
    sha256 = "sha256-HgzYBn0eEkG/HNGSZkWzFufnMDqxBfYUgAl6XzKT+zQ=";
  };

  meta = with lib; {
    homepage = "https://github.com/marnas/tmux-tilish-colemak";
    description = "Colemak version of tmux tilish";
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = with maintainers; [ marnas ];
  };
}
