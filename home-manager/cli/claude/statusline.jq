# Claude Code statusline: "Model: <name> | Ctx: <n>%" from the stdin JSON.
# Colors are Monokai Pro (matching nvim) as truecolor escapes; -j output (raw,
# no trailing newline).
#
# Ctx % is measured against the *usable* budget (0.8 × window), i.e. the
# auto-compact point — 100% means "Claude is about to compact" and the number
# matches Claude's own context indicator. Token count is input + cache
# (excludes output).
#
# Thresholds (% toward auto-compact), tuned for cost — act well before Claude:
#   green  <50%   fine
#   orange 50-74% consider compacting / fresh context at the next break
#   red    >=75%  recompact now, before the window bloats every turn
def col($rgb; $s): "\u001b[38;2;\($rgb)m\($s)\u001b[39m";

(.context_window as $cw
 | if $cw == null then null
   else
     (($cw.context_window_size // 0) * 0.8) as $usable
     | $cw.current_usage as $u
     | (if ($u | type) == "number" then $u
        elif ($u | type) == "object" then
          (($u.input_tokens // 0) + ($u.cache_creation_input_tokens // 0) + ($u.cache_read_input_tokens // 0))
        else null
        end) as $used
     | if $usable > 0 and $used != null
       then ([ $used / $usable * 100, 100 ] | min | floor)
       else null
       end
   end) as $pct

# Render Ctx even before Claude sends context_window data (early renders of a
# fresh session): default to 0% rather than dropping the segment.
| ($pct // 0) as $pct
| col("120;220;232"; "Model: \(.model.display_name // "?")")     # cyan #78dce8
  + col("114;112;114"; " | ")                                    # grey #727072
  + col(
      (if $pct < 50 then "169;220;118"                           # green  #a9dc76
       elif $pct < 75 then "252;152;103"                         # orange #fc9867
       else "255;97;136"                                         # red    #ff6188
       end);
      "Ctx: \($pct)%")
