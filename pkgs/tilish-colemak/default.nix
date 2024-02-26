{ tmuxPlugins
, fetchFromGitHub
}:
tmuxPlugins.mkTmuxPlugin {
  pluginName = "tilish";
  version = "unstable-2023-05-12";
  src = fetchFromGitHub {
    owner = "marnas";
    repo = "tmux-tilish";
    rev = "d81c007f29aa3d81f1381eda58dc1fd0524d55f1";
    sha256 = "sha256-HgzYBn0eEkG/HNGSZkWzFufnMDqxBfYUgAl6XzKT+zQ=";
  };
}

