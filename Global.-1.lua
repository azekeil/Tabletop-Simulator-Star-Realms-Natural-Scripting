--[[
This is a scripted version of Star Realms

Please see the Notebook for more information.
--]]

-- ZONES --

play_zone_guids={'41d774', '7f8b9c', 'eb0d4b', '3d0725'}
play_zones_from_guid = {}

disown_zone_guids={
    explorer='5454ba',
    trade='7a543d'
}
disown_zones_from_guid = {}

owned_zone_guids = {
    White='4d5848',
    Blue='b10362',
    Red='cf8d1c',
    Green='908c52'
}
owned_zones_from_guid = {}

scrap_zone_guid='950853'

all_zone_guids = {}

-- COUNTERS --

pool_counter_guids = {
    trade = {
        White='52a23f',
        Blue='e80226',
        Red='e8f88e',
        Green='bd4473'
    },
    combat = {
        White='22e73a',
        Blue='3ea4f6',
        Red='df3603',
        Green='e58091'
    }
}
pool = {}

-- STATUS --

in_play = {}
faction_counts = {}
turn = ''

-- GLOBALS --

add = 1
remove = -1

-- GAME DATA --

factions = {'red', 'blue', 'green', 'yellow'}

card = {
    Scout = {
        trade = 1
    },
    Viper = {
        combat = 1
    },
    Explorer = {
        cost = 2,
        trade = 2,
        trash = {
            combat = 2
        }
    },
    Cutter = {
        blue = 1,
        cost = 2,
        authority = 4,
        trade = 2,
        blue_ally = {
            combat = 4
        }
    },
    ['Survey Ship'] = {
        yellow = 1,
        cost = 3,
        trade = 1,
        draw_card = 1,
        trash = {
            opponent_discard_card = 1
        }
    },
    ['Federation Shuttle'] = {
        blue = 1,
        cost = 1,
        trade = 2,
        blue_ally = {
            authority = 4
        }
    },
    ['Imperial Frigate'] = {
        yellow = 1,
        cost = 3,
        combat = 4,
        opponent_discard_card = 1,
        yellow_ally = {
            combat = 2
        },
        trash = {
            draw_card = 1
        }
    },
    ['Imperial Fighter'] = {
        yellow = 1,
        cost = 1,
        combat = 2,
        opponent_discard_card = 1,
        yellow_ally = {
            combat = 2
        }
    },
    ['Trade Bot'] = {
        red = 1,
        cost = 1,
        trade = 1,
        scrap_card_in_hand_or_discard = 1,
        red_ally = {
            combat = 2
        }
    },
    ['Blob Wheel'] = {
        green = 1,
        cost = 3,
        combat = 1,
        trash = {
            trade = 3
        },
        base = true,
        defense = 5
    },
    ['Blob Fighter'] = {
        green = 1,
        cost = 1,
        combat = 3,
        green_ally = {
            draw_card = 1
        }
    },
    ['Trade Pod'] = {
        green = 1,
        cost = 2,
        trade = 3,
        green_ally = {
            combat = 2
        }
    },
    ['Missile Bot'] = {
        red = 1,
        cost = 2,
        combat = 2,
        scrap_card_in_hand_or_discard = 1,
        red_ally = {
            combat = 2
        }
    },
    ['Supply Bot'] = {
        red = 1,
        cost = 3,
        trade = 2,
        scrap_card_in_hand_or_discard = 1,
        red_ally = {
            combat = 2
        }
    },
    ['Blob Destroyer'] = {
        green = 1,
        cost = 4,
        combat = 6,
        green_ally = {
            destroy_base = 1,
            scrap_card_in_trade_row = 1
        }
    },
    ['Battle Pod'] = {
        green = 1,
        cost = 2,
        combat = 4,
        scrap_card_in_trade_row = 1,
        green_ally = {
            combat = 2
        }
    },
    ['Embassy Yacht'] = {
        blue = 1,
        cost = 3,
        authority = 3,
        trade = 2,
        if_two_bases_draw_card = 2
    },
    Ram = {
        green = 1,
        cost = 3,
        combat = 5,
        green_ally = {
            combat = 2
        },
        trash = {
            trade = 3
        }
    },
    ['Battle Station'] = {
        red = 1,
        cost = 3,
        trash = {
            combat = 5
        },
        base = true,
        outpost = true,
        defense = 5
    },
    ['Recycling Station'] = {
        yellow = 1,
        cost = 4,
        choice = {
            trade = 1,
            discard_up_to_and_draw_for_each = 2
        },
        base = true,
        outpost = true,
        defense = 4
    },
    Freighter = {
        blue = 1,
        cost = 4,
        trade = 4,
        blue_ally = {
            next_ship_to_top_of_deck = 1
        }
    },
    ['Patrol Mech'] = {
        red = 1,
        cost = 4,
        choice = {
            trade = 3,
            combat = 5
        },
        red_ally = {
            scrap_card_in_hand_or_discard = 1
        }
    },
    Corvette = {
        yellow = 1,
        cost = 2,
        combat = 1,
        draw_card = 1,
        yellow_ally = {
            combat = 2
        }
    },
    ['Trading Post'] = {
        blue = 1,
        cost = 3,
        choice = {
            authority = 1,
            trade = 1
        },
        trash = {
            combat = 3
        },
        base = true,
        outpost = true,
        defense = 4
    },
    ['Space Station'] = {
        yellow = 1,
        cost = 4,
        combat = 2,
        yellow_ally = {
            combat = 2
        },
        trash = {
            trade = 4
        },
        base = true,
        outpost = true,
        defense = 4
    },
    ['Barter World'] = {
        blue = 1,
        cost = 4,
        choice = {
            authority = 2,
            trade = 2
        },
        trash = {
            combat = 5
        },
        base = true,
        defense = 4
    },
    ['The Hive'] = {
        green = 1,
        cost = 5,
        combat = 3,
        green_ally = {
            draw_card = 1
        },
        base = true,
        defense = 5
    },
    Dreadnaught = {
        yellow = 1,
        cost = 7,
        combat = 7,
        draw_card = 1,
        trash = {
            combat = 5
        }
    },
    ['Command Ship'] = {
        blue = 1,
        cost = 8,
        authority = 4,
        combat = 5,
        draw_card = 2,
        blue_ally = {
            destroy_base = 1
        }
    },
    ['Fleet HQ'] = {
        yellow = 1,
        cost = 8,
        all_ships_extra_combat = 1,
        base = true,
        defense = 8
    },
    ['Battle Mech'] = {
        red = 1,
        cost = 5,
        combat = 4,
        scrap_card_in_hand_or_discard = 1,
        red_ally = {
            draw_card = 1
        }
    },
    Flagship = {
        blue = 1,
        cost = 6,
        combat = 5,
        draw_card = 1,
        blue_ally = {
            authority = 5
        }
    },
    ['Missile Mech'] = {
        red = 1,
        cost = 6,
        combat = 6,
        destroy_base = 1,
        red_ally = {
            draw_card = 1
        }
    },
    Mothership = {
        green = 1,
        cost = 7,
        combat = 6,
        draw_card = 1,
        green_ally = {
            draw_card = 1
        }
    },
    ['Defense Center'] = {
        blue = 1,
        cost = 5,
        choice = {
            authority = 3,
            combat = 2
        },
        blue_ally = {
            combat = 2
        },
        base = true,
        outpost = true,
        defense = 5
    },
    ['War World'] = {
        yellow = 1,
        cost = 5,
        combat = 3,
        yellow_ally = {
            combat = 4
        },
        base = true,
        outpost = true,
        defense = 4
    },
    ['Mech World'] = {
        red = 1,
        cost = 5,
        base = true,
        outpost = true,
        defense = 6,
        yellow = 1,
        green = 1,
        blue = 1
    },
    ['Machine Base'] = {
        red = 1,
        cost = 7,
        base = true,
        outpost = true,
        defense = 6,
        draw_card_then_scrap_card_from_hand = 1
    },
    ['Brain World'] = {
        red = 1,
        cost = 8,
        base = true,
        outpost = true,
        defense = 6,
        scrap_up_to_from_hand_or_discard_draw_card_for_each = 2
    },
    Battlecruiser = {
        yellow = 1,
        cost = 6,
        combat = 5,
        draw_card = 1,
        yellow_ally = {
            opponent_discard_card = 1
        },
        trash = {
            draw_card = 1,
            destroy_base = 1
        }

    },
    ['Battle Blob'] = {
        green = 1,
        cost = 6,
        combat = 8,
        green_ally = {
            draw_card = 1
        },
        trash = {
            combat = 4
        }
    },
    ['Royal Redoubt'] = {
        yellow = 1,
        cost = 6,
        combat = 3,
        yellow_ally = {
            opponent_discard_card = 1
        },
        base = true,
        outpost = true,
        defense = 6
    },
    Junkyard = {
        red = 1,
        cost = 6,
        scrap_card_in_hand_or_discard = 1,
        base = true,
        outpost = true,
        defense = 5
    },
    ['Blob World'] = {
        green = 1,
        cost = 8,
        choice = {
            combat = 5,
            draw_a_card_for_every_blob_played_this_turn = true
        },
        base = true,
        defense = 7
    },
    ['Blob Carrier'] = {
        cost = 6,
        green = 1,
        combat = 7,
        green_ally = {
            acquire_ship_for_free_to_top_of_deck = true
        }
    },
    ['Trade Escort'] = {
        cost = 5,
        blue = 1,
        authority = 4,
        combat = 4,
        blue_ally = {
            draw_card = 1
        }
    },
    ['Port of Call'] = {
        cost = 6,
        blue = 1,
        trade = 3,
        base = true,
        outpost = true,
        defense = 6,
        trash = {
            draw_card = 1,
            destroy_base = 1
        }
    },
    ['Central Office'] = {
        cost = 7,
        blue = 1,
        base = true,
        defense = 6,
        trade = 2,
        next_ship_to_top_of_deck = 1,
        blue_ally = {
            draw_card = 1
        }
    },
    ['Stealth Needle'] = {
        cost = 4,
        red = 1,
        clone_ship = true
    }
}

------

function onLoad()
    -- Objects instantiated here
    table.insert(all_zone_guids, scrap_zone_guid)

    for i, v in pairs(disown_zone_guids) do
        disown_zones_from_guid[v] = getObjectFromGUID(v)
        table.insert(all_zone_guids, v)
    end

    for i, v in pairs(owned_zone_guids) do
        owned_zones_from_guid[v] = i
        table.insert(all_zone_guids, v)

        in_play[i] = {}

        faction_counts[i] = {}
        for j, faction in ipairs(factions) do
            faction_counts[i][faction] = 0
        end
    end

    -- Do Play Zones last so it is lowest precedence due to overlapping zones :(
    for i, v in ipairs(play_zone_guids) do
        play_zones_from_guid[v] = true
        table.insert(all_zone_guids, v)
    end

    for i, v in pairs(pool_counter_guids) do
        pool[i] = {}
        for j, w in pairs(v) do
            pool[i][j] = getObjectFromGUID(w)
        end
    end
end

--[[
This is the main routine - it triggers when an object is dropped.
It does three main things:
1) Determine the zone the card was dropped in
2) Set ownership on card
3) Take appropriate action (play/unplay/scrap etc) by manipulating state tables.
--]]
function onObjectDropped(player_color, dropped_object)
    -- We only care if it's a card - cards always have a name
    local cname = dropped_object.getVar('name')
    if cname == nil then return end
    print_d('Card dropped')
    local cowner = dropped_object.getVar('player')

    -- Figure out which zone the object was dropped in
    local obj_guid = dropped_object.getGUID()
    local zone_guid = FindZoneObjectIsIn(obj_guid)
    local in_player_owned_zone = owned_zones_from_guid[zone_guid]
    local in_disown_zone = disown_zones_from_guid[zone_guid]
    local in_play_zone = play_zones_from_guid[zone_guid]
    local in_scrap_zone = false
    if zone_guid == scrap_zone_guid then in_scrap_zone = true end
    local in_explorer_zone = false
    if in_disown_zone == 'explorer' then in_explorer_zone = true end

    -- Unplay played cards before removing the owner!
    if cowner != nil and in_play[cowner][obj_guid] != nil and in_play_zone == nil and not in_scrap_zone then
        if in_play[cowner][obj_guid]['scrapped'] != nil then
            print_d('Replaying Scrapped Card (so we can unplay it cleanly)')
            RePlayScrappedCard(obj_guid, cowner)
        end
        print_d('Unplaying Card')
        UnPlayCardGuid(obj_guid, cowner, remove)
    end

    if in_scrap_zone then
        print_d('Card dropped in scrap zone')
        -- We only process cards that were in play
        if cowner != nil and in_play[cowner][obj_guid] != nil and in_play[cowner][obj_guid]['scrapped'] == nil then
            print_d('Card was in play and not already scrapped; processing')
            ScrapCard(dropped_object)
        end
    end

    -- Set hard ownership in player or disown zones, or soft ownership elsewhere
    if in_player_owned_zone != nil then
        print_d('Setting owner of ' .. obj_guid .. ' to ' .. in_player_owned_zone)
        dropped_object.setVar('player', in_player_owned_zone)
    elseif in_disown_zone != nil then
        print_d('Setting owner of ' .. obj_guid .. ' to nil')
        dropped_object.setVar('player', nil)
    else
        if dropped_object.getVar('player') == nil then
            print_d('Setting owner of ' .. obj_guid .. ' to ' .. player_color)
            dropped_object.setVar('player', player_color)
        end
        -- Put this at the end of the if/else to make the other zones take precedence
        -- because cards physically overlap zones :(
        if in_play_zone then
            -- If the card was previously scrapped, undo that instead of playing it
            if cowner != nil and in_play[cowner][obj_guid] != nil then
                if in_play[cowner][obj_guid]['scrapped'] != nil then
                    print_d('UnScrapping '..in_play[cowner][obj_guid]['played'])
                    RePlayScrappedCard(obj_guid, cowner)
                end
            else
                -- Let's set the turn then - this is done outside of PlayCard
                -- function as we may use PlayCard for automation and don't want
                -- it also changing the turn on us!
                if turn != cowner then
                    ChangeTurn(player_color)
                end
                -- Play after setting owner!
                PlayCard(dropped_object)
            end
        end
    end
    --print_r(faction_counts)
    --RecalculatePools()
end

function PlayCard(obj)
    local obj_guid = obj.getGUID()
    local cname = obj.getVar('name')
    local cowner = obj.getVar('player')
    if cname != nil and cowner != nil then
        print_d('Playing ' .. cname .. ' for ' .. cowner)
        in_play[cowner][obj_guid] = { ['played'] = cname }
        -- Process basic effects
        ProcessCardTable(card[cname], cowner, add, add)
        -- check for ally triggers
        for i, faction in ipairs(factions) do
            if faction_counts[cowner][faction] > 1 then
                -- trigger all ally abilities on all cards that don't already have it
                print_d('Triggering all '..faction..' allies')
                --print_r(in_play)
                for other_guid, j in pairs(in_play[cowner]) do
                    local ocard = getObjectFromGUID(other_guid)
                    local oname = ocard.getVar('name')
                    if not in_play[cowner][other_guid][faction .. '_ally_triggered'] then
                        print_d('Processing ' .. oname)
                        ProcessCardTable(card[oname][faction .. '_ally'], cowner, add, add)
                        in_play[cowner][other_guid][faction .. '_ally_triggered'] = true
                    end
                end
            end
        end
        print_r(in_play)
    end
end

-- This function is called when a player removes a card from play
-- Either because they played it by accident or scrapped cards at end of turn
function UnPlayCardGuid(obj_guid, cowner, faction_change)
    if cowner != nil and obj_guid != nil then
        if in_play[cowner][obj_guid] != nil then
            local cname = in_play[cowner][obj_guid]['played']
            print_d('UnPlaying '..cname..' for '..cowner)
            -- Process basic effects
            ProcessCardTable(card[cname], cowner, remove, faction_change)
            -- check for ally triggers
            for i, faction in ipairs(factions) do
                local faction_ally_triggered = faction .. '_ally_triggered'
                -- Also remove each ally ability for this card if it was triggered
                if in_play[cowner][obj_guid][faction_ally_triggered] then
                    ProcessCardTable(card[cname][faction .. '_ally'], cowner, remove, faction_change)
                    -- Possibly a bit redundant?
                    in_play[cowner][obj_guid][faction .. '_ally_triggered'] = nil
                end
                if faction_counts[cowner][faction] < 2 then
                    -- untrigger all ally abilities on all cards that don't already have it
                    for other_guid, j in pairs(in_play[cowner]) do
                        local oname = in_play[cowner][other_guid]['played']
                        if in_play[cowner][other_guid][faction_ally_triggered] and in_play[cowner][other_guid][faction..'_ally_permanently_triggered'] == nil then
                            ProcessCardTable(card[oname][faction .. '_ally'], cowner, remove, faction_change)
                            in_play[cowner][other_guid][faction_ally_triggered] = nil
                        end
                    end
                end
            end
        end
        in_play[cowner][obj_guid] = nil
    end
end

function ScrapCard(obj)
    local obj_guid = obj.getGUID()
    local cname = obj.getVar('name')
    local cowner = obj.getVar('player')
    -- Mark as scrapped
    in_play[cowner][obj_guid]['scrapped'] = true
    -- 'Permanently' trigger allies (this turn) and record the triggered
    -- card guids on this card
    in_play[cowner][obj_guid]['allies_permanently_triggered'] = {}
    for i, faction in ipairs(factions) do
        in_play[cowner][obj_guid]['allies_permanently_triggered'][faction] = {}
        if card[cname][faction] != nil then
            for other_guid, j in pairs(in_play[cowner]) do
                if in_play[cowner][other_guid][faction .. '_ally_triggered'] then
                    in_play[cowner][other_guid][faction .. '_ally_permanently_triggered'] = true
                    table.insert(in_play[cowner][obj_guid]['allies_permanently_triggered'][faction], other_guid)
                end
            end
        end
    end
    print_r(in_play)
    -- Now actually do the scrap abilities
    ProcessCardTable(card[cname]['trash'], cowner, add, add)
    -- Decrement the factions for new cards (cards already triggered remain so)
    for i, faction in ipairs(factions) do
        if card[cname][faction] != nil then
            faction_counts[cowner][faction] = faction_counts[cowner][faction] - card[cname][faction]
        end
    end
end

function RePlayScrappedCard(obj_guid, cowner)
    if obj_guid != nil and cowner != nil and in_play[cowner][obj_guid] != nil then
        local cname = in_play[cowner][obj_guid]['played']
        ProcessCardTable(card[cname]['trash'], cowner, remove, remove)
        -- This probably breaks if different factions are around now. Probably the
        -- player will need to 'restart' their turn as in real life?
        for i, faction in ipairs(factions) do
            -- Now untrigger the cards that were permanently triggered
            -- (if they're still around)
            for i, acard_guid in pairs(in_play[cowner][obj_guid]['allies_permanently_triggered'][faction]) do
                if in_play[cowner][acard_guid] != nil then
                    in_play[cowner][acard_guid][faction..'_ally_permanently_triggered'] = nil
                end
            end
            -- Don't forget to increment the factions again
            if card[cname][faction] != nil then
                faction_counts[cowner][faction] = faction_counts[cowner][faction] + card[cname][faction]
            end
        end
        in_play[cowner][obj_guid]['scrapped'] = nil
        in_play[cowner][obj_guid]['allies_permanently_triggered'] = nil
    end
end

-- This function deals with processing a single level on a card. That could be
-- the top level which contains the factions and the base actions, or it could
-- be an ally or scrap subtable. All card logic should be implemented here.
function ProcessCardTable(table, player, pool_change, faction_change)
    -- Table == nil will happen if there is no subtable (ally, scrap, etc)
    -- player == nil can be unowned cards - in which case don't process them
    if table == nil or player == nil then return end

    -- Process faction count(s) for the card in the faction_counts table for that player
    for i, faction in ipairs(factions) do
        if table[faction] != nil then
            faction_counts[player][faction] = faction_counts[player][faction] + table[faction] * faction_change
        end
    end

    -- Process combat and trade pools
    for i, v in pairs(pool_counter_guids) do
        local val = table[i]
        if val != nil then
            pool[i][player].setValue(pool[i][player].getValue() + val * pool_change)
        end
    end
end

function ChangeTurn(player)
    -- Don't do any resetting if there was no previous player (i.e. start of the game)
    print_r(faction_counts)
    if player != turn then
        print_d('Changing turn to '..player)
        print_r(in_play)
        if turn != nil and in_play[turn] != nil then
            -- Reset the current player
            for card_guid, i in pairs(in_play[turn]) do
                local cname = in_play[turn][card_guid]['played']
                if in_play[turn][card_guid]['scrapped'] != nil then
                    -- Now unplay the card
                    RePlayScrappedCard(card_guid, turn)
                    UnPlayCardGuid(card_guid, turn, remove)
                else
                    -- For non-scrapped card, just get rid of the 'permanent' triggers
                    for i, faction in ipairs(factions) do
                        in_play[turn][card_guid][faction..'_ally_permanently_triggered'] = nil
                    end
                end
            end
        end
        -- Finally set the turn to the new player
        turn = player
        print_r(faction_counts)
    end
end

function isObjectInZone(object_guid, zone_guid)
    if zone_guid == nil then return false end
    local zone = getObjectFromGUID(zone_guid)
    local objects = zone.getObjects()
    for i, v in ipairs(objects) do
        if v.getGUID() == object_guid then return true end
    end
    return false
end

function FindZoneObjectIsIn(object_guid)
    for i, v in ipairs(all_zone_guids) do
        if isObjectInZone(object_guid, v) then
            return v
        end
    end
    return nil
end

function RecalculatePools()
    print_d('Recalculating Pools')

    -- Reset counters
    for i, v in pairs(pool_counter_guids) do
        for j, w in pairs(v) do
            pool[i][j].setValue(0)
        end
    end

    for i, v in ipairs(play_zones) do
        local objects = v.getObjects()

        for j, w in ipairs(objects) do
            local wname = w.getVar('name')
            local wowner = w.getVar('player')
            if wname != nil and wowner != nil then
                print_d('Found ' .. wname .. ' for ' .. wowner)
                for i, v in pairs(pool_counter_guids) do
                    local val = card[wname][i]
                    if val != nil then
                        pool[i][wowner].setValue(pool[i][wowner].getValue() + val)
                    end
                end
            end
        end
    end
end

function print_d ( t )
    --print(t)
end

function print_r ( t )
    --[[
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        print(indent.."["..pos..'] => "'..val..'"')
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        print(tostring(t).." {")
        sub_print_r(t,"  ")
        print("}")
    else
        sub_print_r(t,"  ")
    end
    print()
    --]]
end