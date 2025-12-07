{ pkgs, ... }: {
  home.file.".hammerspoon/init.lua".text = ''
    -- Media key bindings for MPD control
    local mpc = "${pkgs.mpc}/bin/mpc"

    -- Function to execute mpc commands
    function mpcCommand(cmd)
      hs.task.new(mpc, nil, {cmd}):start()
    end

    -- Intercept actual media keys using eventtap
    mediaKeyTap = hs.eventtap.new({hs.eventtap.event.types.systemDefined}, function(event)
      local systemKey = event:systemKey()
      if not systemKey then return false end

      local key = systemKey.key
      local down = systemKey.down

      -- Only handle key down events
      if not down then return false end

      if key == "PLAY" then
        mpcCommand("toggle")
        return true  -- Prevent default action
      elseif key == "NEXT" or key == "FAST" then
        mpcCommand("next")
        return true
      elseif key == "PREVIOUS" or key == "REWIND" then
        mpcCommand("prev")
        return true
      end

      return false
    end)
    mediaKeyTap:start()

    -- Auto-reload config when it changes
    function reloadConfig(files)
      doReload = false
      for _,file in pairs(files) do
        if file:sub(-4) == ".lua" then
          doReload = true
        end
      end
      if doReload then
        hs.reload()
      end
    end
    myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
  '';
}
