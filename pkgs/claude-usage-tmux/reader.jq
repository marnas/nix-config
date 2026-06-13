# Render the Claude 5h-block usage widget from ccstatusline's on-disk cache.
# Output is byte-identical to ccstatusline's own session-usage + separator +
# reset-timer line (e.g. "Session: 5.0% | Reset: 2hr 29m"), but computed in jq
# so the tmux render path never spawns Node. The reset countdown is derived from
# the absolute sessionResetAt at render time, so it ticks down every redraw.
#
# Duration formatting mirrors ccstatusline's formatDurationFromMs: <1m, then
# "{m}m", "{h}hr", or "{h}hr {m}m".
def fmt($mins):
  if $mins < 1 then "<1m"
  else ($mins / 60 | floor) as $h
  | ($mins % 60) as $m
  | if $h == 0 then "\($m)m"
    elif $m == 0 then "\($h)hr"
    else "\($h)hr \($m)m"
    end
  end;

if .sessionUsage == null then empty
else
  # One-decimal percent without relying on a printf float (matches .toFixed(1)).
  (.sessionUsage * 10 | round) as $t
  | "Session: \($t / 10 | floor).\($t % 10)%" as $pct
  | if .sessionResetAt == null then
      # No active 5h block: the usage API returns five_hour: null once a block
      # expires with no new usage, and ccstatusline caches that as sessionUsage 0
      # with no sessionResetAt. The expired block's numbers are obsolete, so
      # render the real state — 0%, no countdown — rather than going blank.
      $pct
    else
      # sessionResetAt is UTC ISO8601 with fractional seconds and a +00:00 offset;
      # strip the fraction and normalize the offset to Z so fromdateiso8601 parses it.
      (.sessionResetAt | sub("\\.[0-9]+"; "") | sub("\\+00:00$"; "Z") | fromdateiso8601) as $reset
      | (($reset - now) / 60 | floor) as $mins
      # A live 5h block always resets in the future. A past reset means no fresh
      # fetch happened after the block rolled over (the usage API was unreachable),
      # so the cached %/reset are stale — render an unmistakable marker rather than a
      # plausible-but-wrong number. See claude-usage-refresh: the cache can freeze
      # when the OAuth usage endpoint times out / rate-limits.
      | if $mins < 0 then "usage: stale"
        else "\($pct) | Reset: \(fmt($mins))"
        end
    end
end
