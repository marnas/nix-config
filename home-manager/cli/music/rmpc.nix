{ config, musicDirectory, ... }: {
  programs.rmpc = {
    enable = true;

    config = ''
      #![enable(implicit_some)]
      #![enable(unwrap_newtypes)]
      #![enable(unwrap_variant_newtypes)]
      (
      	lyrics_dir: Some("${musicDirectory}"),
      	enable_config_hot_reload: true,
      	theme: Some("theme"),
      	tabs: [
      		(
      		 	name: "Queue",
      		 	pane: Pane(Queue),
      		),
      		(
      		 	name: "Artists",
      		 	pane: Pane(Directories),
      		),
      		(
      		 	name: "Albums",
      		 	pane: Pane(Albums),
      		),
      		(
      		 	name: "Search",
      		 	pane: Pane(Search),
      		),
      		(
      		 	name: "Lyrics",
      		 	pane: Pane(Lyrics),
      		),
      	],
      	keybinds: (
      		global: {
            ":": 			 CommandMode,
            "<Tab>": 	 NextTab,
            "<S-Tab>": PreviousTab,
          	"1": 			 SwitchToTab("Queue"),
          	"2": 			 SwitchToTab("Artists"),
          	"3": 			 SwitchToTab("Albums"),
          	"4": 			 SwitchToTab("Search"),
          	"5": 			 SwitchToTab("Lyrics"),
      			"q": 			 Quit,
            "f": 			 SeekForward,
            "z": 			 ToggleRepeat,
            "x": 			 ToggleRandom,
            "c": 			 ToggleConsume,
            "v": 			 ToggleSingle,
            "b": 			 SeekBack,
            "~": 			 ShowHelp,
            "u": 			 Update,
            "U": 			 Rescan,
            "I": 			 ShowCurrentSongInfo,
            "O": 			 ShowOutputs,
            "P": 			 ShowDecoders,
            "R": 			 AddRandom,
      		},
      		navigation: {
          	"k":         Up,
          	"j":         Down,
          	"h":         Left,
          	"l":         Right,
          	"<Up>":      Up,
          	"<Down>":    Down,
          	"<Left>":    Left,
          	"<Right>":   Right,
          	"<C-k>":     PaneUp,
          	"<C-j>":     PaneDown,
          	"<C-h>":     PaneLeft,
          	"<C-l>":     PaneRight,
          	"<C-u>":     UpHalf,
          	"N":         PreviousResult,
          	"a":         Add,
          	"A":         AddAll,
          	"r":         Rename,
          	"n":         NextResult,
          	"g":         Top,
          	"<Space>":   Select,
          	"<C-Space>": InvertSelection,
          	"G":         Bottom,
          	"<CR>":      Confirm,
          	"i":         FocusInput,
          	"J":         MoveDown,
          	"<C-d>":     DownHalf,
          	"/":         EnterSearch,
          	"<C-c>":     Close,
          	"<Esc>":     Close,
          	"K":         MoveUp,
          	"D":         Delete,
          	"B":         ShowInfo,
          	"<C-z>":     ContextMenu(),
          	"<C-s>":     Save(kind: Modal(all: false, duplicates_strategy: Ask)),
      		},
          queue: {
          	"D": 		DeleteAll,
          	"<CR>": Play,
          	"a": 		AddToPlaylist,
          	"d": 		Delete,
          	"C": 		JumpToCurrent,
          	"X": 		Shuffle,
          },
      	),
      )
    '';
  };

  home.file."${config.xdg.configHome}/rmpc/themes/theme.ron".source =
    ./rmpc-theme.ron;
}
