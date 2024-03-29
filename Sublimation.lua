--[[
* Ashita - Copyright (c) 2014 - 2017 atom0s [atom0s@live.com]
*
* This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
* To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/ or send a letter to
* Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
*
* By using Ashita, you agree to the above license and its terms.
*
*      Attribution - You must give appropriate credit, provide a link to the license and indicate if changes were
*                    made. You must do so in any reasonable manner, but not in any way that suggests the licensor
*                    endorses you or your use.
*
*   Non-Commercial - You may not use the material (Ashita) for commercial purposes.
*
*   No-Derivatives - If you remix, transform, or build upon the material (Ashita), you may not distribute the
*                    modified material. You are, however, allowed to submit the modified works back to the original
*                    Ashita project in attempt to have it added to the original project.
*
* You may not apply legal terms or technological measures that legally restrict others
* from doing anything the license permits.
*
* No warranties are given.
]]--

_addon.author   = 'Based off atom0s fps addon modified by Tornac';
_addon.name     = 'Sublimation';
_addon.version  = '1.0.0';

require 'common'

----------------------------------------------------------------------------------------------------
-- Sublimation Configuration
----------------------------------------------------------------------------------------------------
local default_config =
{
    font =
    {
        family      = 'Arial',
        size        = 12,
        color       = math.d3dcolor(255, 255, 0, 0),
		bgcolor     = math.d3dcolor(200, 0, 0, 0),
        bgvisible   = true,
		bold		= true,
        position    = { 702, 525 }
    },
		tic = 2,
    format = 'Sublimation: %.1f'
};
local Sublimation_config = default_config;

----------------------------------------------------------------------------------------------------
-- Sublimation Variables
----------------------------------------------------------------------------------------------------
local Sublimation = { };
Sublimation.count        = 0;
Sublimation.timer        = 0;
Sublimation.mp           = 0;
Sublimation.show         = true;
Sublimation.objTimerTic  = 0;
Sublimation.objDelayTic  = 3.00;
Sublimation.ticZone      = false
Sublimation.ZoneoutTimer = nil

----------------------------------------------------------------------------------------------------
-- func: print_help
-- desc: Displays a help block for proper command usage.
----------------------------------------------------------------------------------------------------
local function print_help(cmd, help)
    -- Print the invalid format header..
    print('\31\200[\31\05' .. _addon.name .. '\31\200]\30\01 ' .. '\30\68Invalid format for command:\30\02 ' .. cmd .. '\30\01'); 

    -- Loop and print the help commands..
    for k, v in pairs(help) do
        print('\31\200[\31\05' .. _addon.name .. '\31\200]\30\01 ' .. '\30\68Syntax:\30\02 ' .. v[1] .. '\30\71 ' .. v[2]);
    end
end

----------------------------------------------------------------------------------------------------
-- func: load
-- desc: Event called when the addon is being loaded.
----------------------------------------------------------------------------------------------------
ashita.register_event('load', function()
    -- Load the configuration file..
    Sublimation_config = ashita.settings.load_merged(_addon.path .. '/settings/Sublimation.json', Sublimation_config);

    -- Create the font object..
    local f = AshitaCore:GetFontManager():Create('__Sublimation_addon');
    f:SetColor(Sublimation_config.font.color);
    f:SetFontFamily(Sublimation_config.font.family);
    f:SetFontHeight(Sublimation_config.font.size);
    f:SetPositionX(Sublimation_config.font.position[1]);
    f:SetPositionY(Sublimation_config.font.position[2]);
    f:SetText('');
    f:SetVisibility(Sublimation.show);
	f:GetBackground():SetColor(Sublimation_config.font.bgcolor );
    f:GetBackground():SetVisibility(Sublimation_config.font.bgvisible );
end);

----------------------------------------------------------------------------------------------------
-- func: unload
-- desc: Event called when the addon is being unloaded.
----------------------------------------------------------------------------------------------------
ashita.register_event('unload', function()
    -- Get the font object..
    local f = AshitaCore:GetFontManager():Get('__Sublimation_addon');

    -- Update the configuration position..
    Sublimation_config.font.position = { f:GetPositionX(), f:GetPositionY() };

    -- Save the configuration file..
    ashita.settings.save(_addon.path .. '/settings/Sublimation.json', Sublimation_config);

    -- Delete the font object..
    AshitaCore:GetFontManager():Delete('__Sublimation_addon');
end);

----------------------------------------------------------------------------------------------------
-- func: incoming_packet
-- desc: Called when a packet is recived.
----------------------------------------------------------------------------------------------------
ashita.register_event('incoming_packet', function(id, size, packet, packet_modified, blocked)
	if id == 0x00B and Sublimation.mp ~= 0 then
		Sublimation.ZoneoutTimer = os.clock()
		Sublimation.ticZone = true;
	end
	return false;
end);

----------------------------------------------------------------------------------------------------
-- func: command
-- desc: Event called when a command was entered.
----------------------------------------------------------------------------------------------------
ashita.register_event('command', function(command, ntype)
    -- Get the arguments of the command..
    local args = command:args();
    if (args[1] ~= '/Sublimation') then
        return false;
    end

    -- Toggle the Sublimation visibility..
    if (#args == 1 or args[2] == 'show') then
        Sublimation.show = not Sublimation.show;
        return true;
    end

    -- Set the Sublimation color..
    if (#args >= 6 and args[2] == 'color') then
        font_config.font.color = math.d3dcolor(tonumber(args[3]), tonumber(args[4]), tonumber(args[5]),tonumber(args[6]));
        local f = AshitaCore:GetFontManager():Get('__Sublimation_addon');
        if (f ~= nil) then f:SetColor(font_config.font.color); end
        return true;
    end

    -- Set the font family and height..
    if (#args >= 4 and args[2] == 'font') then
        font_config.font.family = args[3];
        font_config.font.size = tonumber(args[4]);
        local f = AshitaCore:GetFontManager():Get('__Sublimation_addon');
        if (f ~= nil) then 
            f:SetFontFamily(font_config.font.family);
            f:SetFontHeight(font_config.font.size); 
        end
        return true;
    end

    -- Prints the addon help..
    print_help('/Sublimation', {
        { '/Sublimation show',                  '- Toggles the Sublimation display on and off.' },
        { '/Sublimation color [a] [r] [g] [b]', '- Sets the Sublimation display color.' },
        { '/Sublimation font [name] [size]',    '- Sets the Sublimation display font family and height.' },
    });
    return true;
end);

----------------------------------------------------------------------------------------------------
-- func: render
-- desc: Event called when the addon is being rendered.
----------------------------------------------------------------------------------------------------
ashita.register_event('render', function()
	local MainJob   = AshitaCore:GetDataManager():GetPlayer():GetMainJob();
    local SubJob    = AshitaCore:GetDataManager():GetPlayer():GetSubJob();
	local buffs   = AshitaCore:GetDataManager():GetPlayer():GetBuffs();
	
	Sublimation.tic       = 0;
	
    -- Get the font object..
    local f = AshitaCore:GetFontManager():Get('__Sublimation_addon');
    if (f == nil) then return; end

    -- Set the font visibility..
    f:SetVisibility(Sublimation.show);

    -- Skip calculations if font is disabled..
    if (Sublimation.show == false) then return; end
	
	-- Checking for Sch main or Sub.
    if (MainJob ~= 20 and SubJob ~= 20) then return; end
 
    -- Check for Active or Complete Sublimation hide the addon if neither is present.
    for i = 0,31 do
       local buff = buffs[i];
       if buff == 187 then
          Sublimation.tic = 1
       elseif buff == 188 then
          Sublimation.tic = 2
       elseif (i == #buffs and Sublimation.tic == 0 and Sublimation.ticZone == false) then
	      Sublimation.mp = 0;
	   end
    end
	
	if Sublimation.ZoneoutTimer ~= nil then
		if Sublimation.tic == 1 then
			if os.clock() >= Sublimation.ZoneoutTimer + 19 and Sublimation.mp ~= 0 then
				Sublimation.mp = Sublimation.mp + (Sublimation_config.tic)
				Sublimation.ticZone = false;
				Sublimation.ZoneoutTimer = nil;
			end
		end
	end
		
	-- Tic counter 2mp/tic.
	if (Sublimation.tic == 1) then
       if  (os.clock() >= (Sublimation.objTimerTic + Sublimation.objDelayTic)) then
          Sublimation.objTimerTic = os.clock();
          Sublimation.mp = Sublimation.mp + (Sublimation_config.tic);
       end
	end
	
    -- Update the Sublimation font..
	if Sublimation.mp ~= 0 then
    f:SetText(string.format(Sublimation_config.format, Sublimation.mp));
	else
	f:SetText('');
	end
end);