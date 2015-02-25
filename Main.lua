local HookedIntoIRChat = false

function Initialize(Plugin)
	Plugin:SetName( "IRChat API Test" )
	Plugin:SetVersion( 1 )

	cPluginManager:AddHook(cPluginManager.HOOK_PLUGINS_LOADED,        OnPluginsLoaded);
	
	LOG("[IRChat API Test] Version " .. Plugin:GetVersion() .. ", initialised")
	
	return true
end

function OnDisable()
	LOG("[IRChat API Test] Disabled")
end

-- Avialable callbacks:
--    OnSendFromEndpoint(Endpoint, Tag, From, Message)
--    OnSendToEndpoint(Endpoint, Tag, From, Message)
-- You can return true to prevent further actions related to the invoked function
-- All callbacks are called before the processing begins, so plugins can change
-- the message, endpoint it originated from, tag or player name, 
-- (by returning values in the false, Endpoint, Tag, From, Message form - you need to specify all of them)
-- this can also be used as a notification - in that case plugins shouldn't return anything


function OnSendFromEndpoint(Endpoint, Tag, From, Message)
	LOG("[IRChat API Test] FROM " .. Endpoint .. " " .. Tag .. " " .. From .. " " .. Message)
	-- If we want to cancel the event
	--return true
	-- If we want to modify the event
	--return false, Endpoint, "[AAA] " .. Tag, From .. " abcdef", "Test123 " .. Message 
	-- Don't return anything if all you want is a notification
end

function OnSendToEndpoint(Endpoint, Tag, From, Message)
	LOG("[IRChat API Test] TO " .. Endpoint .. " " .. Tag .. " " .. From .. " " .. Message)
	-- You can implement custom endpoints with this
	-- Ex. 
	if Endpoint == "CustomTestEndpoint" then
		-- Handle the endpoint somehow
		if From == "" then
			LOG("[IRChat API Test] [CustomTestEndpoint] " .. Tag .. Message)
		else
			LOG("[IRChat API Test] [CustomTestEndpoint] " .. Tag .. "<" .. From .. "> " .. Message)
		end
		return true
	end
	-- If we want to cancel the event
	-- return true
	-- If we want to modify the event
	-- return false, Endpoint, "[AAA] " .. Tag, From .. " abcdef", "Test123 " .. Message 
	-- Don't return anything if all you want is a notification
end

function HookingError(PluginName, ErrorCode, ErrorDesc, ErrorResult)
	LOGINFO("[IRChat API Test] Couldn't hook into " .. PluginName)
	LOGINFO("[IRChat API Test] Error " .. ErrorCode .. ": " .. ErrorDesc)
	LOGINFO("[IRChat API Test] " .. ErrorResult)
end

function OnPluginsLoaded() 
	local IRChatHandle = cPluginManager:Get():GetPlugin("IRChat")
	if IRChatHandle ~= nil then
		if IRChatHandle:GetVersion() >= 4 then
			if cPluginManager:CallPlugin("IRChat", "AddCallback", "OnSendFromEndpoint", "IRChatAPITest", "OnSendFromEndpoint") == true then
				LOG("[IRChat API Test] Hooked into IRChat - OnSendFromEndpoint")
			else 
				HookedIntoIRChat = true
				HookingError("IRChat", 1, "CallPlugin didn't return true - OnSendFromEndpoint", "")
			end
			if cPluginManager:CallPlugin("IRChat", "AddCallback", "OnSendToEndpoint", "IRChatAPITest", "OnSendToEndpoint") == true then
				LOG("[IRChat API Test] Hooked into IRChat - OnSendToEndpoint")
			else 
				HookedIntoIRChat = true
				HookingError("IRChat", 1, "CallPlugin didn't return true - OnSendToEndpoint", "")
			end
			if HookedIntoIRChat == true then
				HookedIntoIRChat = false
			else
				HookedIntoIRChat = true
			end
		else
			HookingError("IRChat", 2, "Your IRChat is outdated, the minimum version is 4", "")
		end
	else
		HookingError("IRChat", 3, "IRChat not found", "")
	end	
end
