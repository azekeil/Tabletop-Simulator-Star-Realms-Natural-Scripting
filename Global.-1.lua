--[[
This is a scripted version of Star Realms

On Steam Workshop:
http://steamcommunity.com/sharedfiles/filedetails/?id=772422344
And on github:
https://github.com/azekeil/Tabletop-Simulator-Star-Realms-Natural-Scripting

Version 1.3

Please see the Notebook for more information.
--]]

function onLoad()
    -- Objects instantiated now
    for i, v in pairs(scrap_zone_guids) do
        scrap_zones_from_guid[v] = i
        table.insert(all_zone_guids, v)
    end

    for i, v in ipairs(buy_zone_guids) do
        buy_zones_from_guid[v] = true
        table.insert(all_zone_guids, v)
    end

    for i, v in pairs(disown_zone_guids) do
        disown_zones_from_guid[v] = i
        table.insert(all_zone_guids, v)
    end

    for i, v in pairs(owned_zone_guids) do
        owned_zones_from_guid[v] = i
        table.insert(all_zone_guids, v)

        in_play[i] = {}

        authority[i] = getObjectFromGUID(authority_guids[i])
        authority[i].createButton({
            click_function='MoveAllToDiscards',
            function_owner=nil,
            label='Tidy Up',
            position={1,0.2,-2},
            rotation={0,0,-180},
            width=500,
            height=200
        })
        authority_player_from_guids[authority_guids[i]] = i
        text_obj[i] = getObjectFromGUID(text_guids[i])

        -- Now that stuff has been populated, initialise status.
        status[i] = {}
        ResetPlayer(i, true)

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
end

function MoveAllToDiscards(obj)
    local player = authority_player_from_guids[obj.getGUID()]
    print_d(player..' tidy up button pressed')
    -- Reset them
    ResetPlayer(player, false)
    -- Now move all their non-base, non-scrapped cards in play
    local offset=0
    for card_guid, j in pairs(in_play[player]) do
        if j['scrapped'] == nil and card[j['played']]['base'] == nil then
            MoveToDiscard(getObjectFromGUID(card_guid), player, offset)
            offset = offset + 0.1
        end
    end
end

--[[
This routine is just to manage buying things from the trade row
--]]
function onObjectPickedUp(player_color, picked_up_object)
    -- We only care if it's a card - cards always have a name
    local cname = picked_up_object.getVar('name')
    if cname == nil then return end

    -- We also only care if it's a card in the trade or explorer zones
    local obj_guid = picked_up_object.getGUID()
    local zone_guid = FindZoneObjectIsIn(obj_guid)
    if disown_zones_from_guid[zone_guid] != 'trade' and scrap_zones_from_guid[zone_guid] != 'explorer' then return end

    BuyCard(obj_guid, player_color, card[cname]['cost'])
    -- Only update the statustext if it's that player's turn
    if turn == player_color then UpdateStatusText(player_color) end
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
    local in_scrap_zone = scrap_zones_from_guid[zone_guid]
    local in_buy_zone = buy_zones_from_guid[zone_guid]

    -- Unplay played cards before removing the owner!
    if cowner != nil and in_play[cowner][obj_guid] != nil then
        if in_play_zone == nil and in_scrap_zone == nil then
            if in_play[cowner][obj_guid]['scrapped'] != nil then
                print_d('Replaying Scrapped Card (so we can unplay it cleanly)')
                RePlayScrappedCard(obj_guid, cowner)
            end
            print_d('Unplaying Card')
            UnPlayCardGuid(obj_guid, cowner, remove)
            UpdateStatusText(player_color)
        end

        if in_scrap_zone != nil then
            print_d('Card dropped in scrap/explorer zone')
            -- We only process cards that were in play
            if in_play[cowner][obj_guid]['scrapped'] == nil then
                print_d('Card was in play and not already scrapped; processing')
                ScrapCard(obj_guid, cowner)
                UpdateStatusText(player_color)
            end
        end
    end

    -- Set hard ownership in player or disown zones, or soft ownership elsewhere
    if in_player_owned_zone != nil then
        print_d('Setting owner of ' .. obj_guid .. ' to ' .. in_player_owned_zone)
        dropped_object.setVar('player', in_player_owned_zone)
        UpdateStatusText(player_color)
    elseif in_disown_zone != nil then
        print_d('Setting owner of ' .. obj_guid .. ' to nil')
        dropped_object.setVar('player', nil)
        UnBuyCard(obj_guid, player_color)
        -- Only update the statustext if it's that player's turn
        if turn == player_color then UpdateStatusText(player_color) end
    else
        if dropped_object.getVar('player') == nil then
            print_d('Setting owner of ' .. obj_guid .. ' to ' .. player_color)
            dropped_object.setVar('player', player_color)
        end

        if in_buy_zone != nil then
            print_d('Dropped in buy zone!')
            -- If the card was bought (this turn) then it is moved to the
            -- discards. If not we treat the buy zone like the rest of the
            -- play zone
            if status[player_color]['bought'][obj_guid] != nil then
                MoveToDiscard(dropped_object, player_color, 0)
            else--
                in_play_zone = true
            end
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
                -- Card was already played but not scrapped - do nothing
            else
                -- Let's set the turn then - this is done outside of PlayCard
                -- function as we may use PlayCard for automation and don't want
                -- it also changing the turn on us!
                ChangeTurn(player_color)
                -- Play after setting owner!
                PlayCard(dropped_object)
                UpdateStatusText(player_color)
            end
        end
    end
    --print_r(faction_counts)
    --RecalculatePools()
end

--[[
This function handles when card objects are destroyed, which happens when
one card is dropped on top of another card or deck of cards. When the deck
is created the individual card objects are destroyed. Here we take them out
of play if they were in play. This is to properly support the natural user
desire to group the cards at the end of a turn to easily dispose of them.
--]]
function onObjectDestroyed(dying_object)
    -- For some reason when you change player colour, this function is called
    -- with an object with no guid (perhaps it's a Player object that is being
    -- destroyed?). Let's just ignore these..
    if dying_object.getGUID() == nil then return end
    print_d(dying_object.getGUID()..' is being destroyed!')
    local obj_guid = dying_object.getGUID()
    for player, i in pairs(owned_zone_guids) do
        if in_play[player][obj_guid] != nil then
            if in_play[player][obj_guid]['scrapped'] == nil then
                UnPlayCardGuid(obj_guid, player, remove)
                UpdateStatusText(player)
                return
            end
        end
    end
end

function PlayCard(obj)
    local obj_guid = obj.getGUID()
    local cname = obj.getVar('name')
    local cowner = obj.getVar('player')
    if cname == nil or cowner == nil then return end
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
                local oname = j['played']
                if not j[faction .. '_ally_triggered'] then
                    print_d('Processing ' .. oname)
                    ProcessCardTable(card[oname][faction .. '_ally'], cowner, add, add)
                    j[faction .. '_ally_triggered'] = true
                end
            end
        end
    end
    print_r(in_play)
end

-- This function is called when a player removes a card from play
-- Either because they played it by accident or scrapped cards at end of turn
function UnPlayCardGuid(obj_guid, cowner, faction_change)
    if cowner == nil or obj_guid == nil then return end
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
                    local oname = j['played']
                    if j[faction_ally_triggered] and j[faction..'_ally_permanently_triggered'] == nil then
                        ProcessCardTable(card[oname][faction .. '_ally'], cowner, remove, faction_change)
                        j[faction_ally_triggered] = nil
                    end
                end
            end
        end
        in_play[cowner][obj_guid] = nil
    end
end

function ScrapCard(obj_guid, cowner)
    if obj_guid == nil or cowner == nil or in_play[cowner][obj_guid] == nil then return end
    local cname = in_play[cowner][obj_guid]['played']
    -- Mark as scrapped
    in_play[cowner][obj_guid]['scrapped'] = true
    -- 'Permanently' trigger allies (this turn) and record the triggered
    -- card guids on this card
    in_play[cowner][obj_guid]['allies_permanently_triggered'] = {}
    for i, faction in ipairs(factions) do
        in_play[cowner][obj_guid]['allies_permanently_triggered'][faction] = {}
        if card[cname][faction] != nil then
            for other_guid, j in pairs(in_play[cowner]) do
                if j[faction .. '_ally_triggered'] then
                    j[faction .. '_ally_permanently_triggered'] = true
                    table.insert(j['allies_permanently_triggered'][faction], other_guid)
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
    if obj_guid == nil or cowner == nil or in_play[cowner][obj_guid] == nil then return end
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

    -- Process pools
    for i, v in pairs(pool_list) do
        local val = table[v]
        if val != nil then
            status[player][v] = status[player][v] + val * pool_change
        end
    end
end

function ResetPlayer(player, reset_pools)
    for card_guid, i in pairs(in_play[player]) do
        local cname = i['played']
        if i['scrapped'] != nil then
            -- Now unplay the card
            RePlayScrappedCard(card_guid, player)
            UnPlayCardGuid(card_guid, player, remove)
        else
            -- For non-scrapped cards still in play, just get rid of the 'permanent' triggers
            for j, faction in ipairs(factions) do
                i[faction..'_ally_permanently_triggered'] = nil
            end
        end
    end
    -- Reset the statuses
    status[player]['spent'] = 0
    status[player]['bought'] = {}

    if reset_pools then
        for i, p in ipairs(pool_list) do
            status[player][p] = 0
        end
    end

    -- Blank the old status (with a single space)
    text_obj[player].TextTool.setValue(' ')
end

function ChangeTurn(player)
    -- Don't do any resetting if there was no previous player (i.e. start of the game)
    print_r(faction_counts)
    if player == turn then return end
    print_d('Changing turn to '..player)
    print_r(in_play)
    if turn != nil and in_play[turn] != nil then
        -- Reset the current player
        ResetPlayer(turn, true)
    end
    -- Finally set the turn to the new player
    turn = player
    print_r(faction_counts)
end

function UpdateStatusText(player)
    if player == nil then return end
    local trade = status[player]['trade']
    local text = trade - status[player]['spent']..'/'..trade..' trade\n'
    text = text .. status[player]['combat']..' combat\n'
    text = text .. status[player]['authority']..' authority\n'
    text_obj[player].TextTool.setValue(text)
end

function MoveToDiscard(obj, player, yoffset)
    if obj == nil or player != obj.getVar('player') or yoffset == nil then return end
    local pos = discard_pos['position'][player]
    pos[2] = pos[2] + yoffset
    obj.setRotationSmooth(discard_pos['rotation'][player], false, false)
    obj.setPositionSmooth(pos, false, false)
end

function BuyCard(obj_guid, player, amount)
    if obj_guid == nil or status[player]['bought'][obj_guid] != nil then return end
    status[player]['spent'] = status[player]['spent'] + amount
    status[player]['bought'][obj_guid] = amount
end

function UnBuyCard(obj_guid, player)
    if obj_guid == nil or status[player]['bought'][obj_guid] == nil then return end
    status[player]['spent'] = status[player]['spent'] - status[player]['bought'][obj_guid]
    status[player]['bought'][obj_guid] = nil
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

function print_d ( t )
    --print(t)
end

function print_r ( t )
    --print_r2(t)
end

function print_r2 ( t )
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
end

-- ZONES --

play_zone_guids={'3d0725', '7f8b9c', 'cbfb3a', 'bb862c'}
play_zones_from_guid = {}

disown_zone_guids={
    trade='7a543d'
}
disown_zones_from_guid = {}

owned_zone_guids = {
    White='01a7bd',
    Blue='2ab544',
    Red='e101d9',
    Green='0852ac'
}
owned_zones_from_guid = {}

scrap_zone_guids = {
    scrap='950853',
    explorer='5454ba'
}
scrap_zones_from_guid = {}

buy_zone_guids = {'9cae45', 'cfe001'}
buy_zones_from_guid = {}

all_zone_guids = {}

-- OBJECTS --

authority_guids = {
    White='7a4bdb',
    Blue='29dba5',
    Red='1695b7',
    Green='9df816'
}
authority_player_from_guids = {}
authority = {}

text_guids = {
    White='8997dd',
    Blue='92567a',
    Red='e04549',
    Green='295e52'
}
text_obj = {}

-- POSITIONS --

discard_pos = {
    position = {
        White = {27.7580966949463, 2.0415952205658, -22.364372253418},
        Blue = {27.5576362609863,2.02753210067749,22.1673812866211},
        Red = {-27.6587677001953,2.03530836105347,-22.2438640594482},
        Green = {-27.6822872161865,2.02753210067749,22.6238460540771}
    },
    rotation = {
        White = {0, 180, 0},
        Blue = {0, 0, 0},
        Red = {0, 180, 0},
        Green = {0, 0, 0}
    }
}
-- STATUS --

pool_list = {'trade', 'combat', 'authority'}

in_play = {}
faction_counts = {}
status = {}
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