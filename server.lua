-- prop_hide (server) ─ registers the ACE-restricted /prophideinfo diagnostic command.
-- The command itself does nothing sensitive on the server; it just asks the calling
-- player's client to scan nearby entities and print them to that player's F8 console.
-- Registering it `restricted` means only principals with the matching ACE can run it:
--   add_ace group.admin command.prophideinfo allow

if not Config.EnableCommands then return end

RegisterCommand('prophideinfo', function(source)
    if source == 0 then
        print('[prop_hide] /prophideinfo must be run in-game - it scans the entities around a player.')
        return
    end
    TriggerClientEvent('prop_hide:runInfo', source)
end, true)
