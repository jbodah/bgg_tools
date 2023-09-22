## Replay value

```
games = BggTools::Search.search(min_voters: 700, no_expansions: true)

items = games.to_items; items.group_by(&method(:get_cohort)).map { |cohort, c_games| [cohort, c_games.sort_by { |cg| -cg.nth_percentile_playcount(0.1) }] }.map { |c, c_games| [c, c_games.map(&:item_name)] }

items.group_by(&method(:get_cohort)).map { |cohort, c_games| [cohort, c_games.sort_by { |cg| -cg.nth_percentile_playcount(0.1) }] }.sort_by { |c, _| [c[1], c[0]] }.map { |c, g| [c, g.first(20)] }.map { |c, cg| item_id = nil; body = ""; weight, t = c; item_id = cg[0].item_id; body << "[size=18][b]#{t} minutes, weight: #{weight}[/b][/size]\n\n"; [cg[0..9], cg[10..-1]].each { |ggs| next if ggs.nil?; ggs.each { |gg| body << gg.thumbnail_bcc(size: "square inline") }; body << "\n" if ggs.any? }; body << "\n"; cg.each { |gg| body << "#{gg.nth_percentile_playcount(0.1)} plays - #{gg.item_bcc_link}" << "\n" }; [item_id, body] }.pipe_to_list(list)
```
