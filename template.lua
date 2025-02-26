EventHandler.EndGeneration:Connect(function(v185)
    -- v185 = [someCardData, floorNumber, cardCount]
    local floorReached = v185[2]  -- floor
    local cardsReceived = v185[3] -- number of cards

    -- The game prints something like:
    local endMessage = "You reached floor " .. floorReached .. " and gained " .. cardsReceived .. " cards!!"
    print(endMessage)

    -- If the user wants a webhook ping for infinite end:
    if _G.pingOnInfiniteEnd and _G.discordWebhook and _G.discordWebhook ~= "" then
        local HttpService = game:GetService("HttpService")
        local requestFunction = syn and syn.request or http and http.request or http_request or request
        if requestFunction then
            
            -- We build an embed with a red bar using "color"
            local embedData = {
                title = "**Multiverse of Cards**",
                description = "User: " .. player.Name 
                    .. "\n**Infinite Results:**"
                    .. "\nFloor Reached: " .. floorReached
                    .. "\nCards Received: " .. cardsReceived,
                color = 16711680  -- Red (#FF0000) in decimal
            }

            local payload = {
                embeds = { embedData }  -- embed array
            }

            requestFunction({
                Url = _G.discordWebhook,
                Method = "POST",
                Body = HttpService:JSONEncode(payload),
                Headers = { ["Content-Type"] = "application/json" }
            })
            print("Sent infinite end embed to webhook with red bar.")
        else
            warn("No HTTP request function available for infinite end embed!")
        end
    end
end)
