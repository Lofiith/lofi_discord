CreateThread(function()
    while true do
        Wait(0)

        if NetworkIsPlayerActive(PlayerId()) then
            Wait(500)
            TriggerServerEvent('lofi_discord:playerReady')
            break
        end
    end
end)
