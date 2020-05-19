-- Author      : RandyBobandy
-- Create Date : 5/17/2020 4:23:39 PM

warriorTable = {};
warriorAuditTable = {};

warriorTableCount = 0;

-- list of tuples of the name of the sunderer and the checkbox indicating if the warrior has used sunder.
warriorAuditTable = {};

SLASH_SUNDERER1, SLASH_SUNDERER2 = '/sun', '/sunderer';

function SlashCmdList.SUNDERER(msg, ...)
    if (msg == 'show') then
        Frame1:Show();
    elseif (msg == 'hide') then
        Frame1:Hide();
    else 
        print ("Sunderer: Arguments to /sun or /sunderer: \n Hide - Hide the Sunderer frame. \n Show - Show the Sunderer frame.");
    end
end

function beginTrackingSunderers()
    -- Reinitialize the starting tables.
    warriorTable = {};
    warriorAuditTable = {};
    warriorTableCount = 0;	
    
    Frame1:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
	
    getWarriorsInRaid();
    clearSundererList();
    fillSundererList();
end

function clearSundererList()
    sundererOne:SetText("");
    sundererTwo:SetText("");
    sundererThree:SetText("");
    sundererFour:SetText("");
    sundererFive:SetText("");
    
    sundererChkBtnOne:SetChecked(false);
    sundererChkBtnTwo:SetChecked(false);
    sundererChkBtnThree:SetChecked(false);
    sundererChkBtnFour:SetChecked(false);
    sundererChkBtnFive:SetChecked(false);
end

function fillSundererList()
    setSundererText(sundererOne, sundererChkBtnOne);
    setSundererText(sundererTwo, sundererChkBtnTwo);
    setSundererText(sundererThree, sundererChkBtnThree);
    setSundererText(sundererFour, sundererChkBtnFour);
    setSundererText(sundererFive, sundererChkBtnFive);
end

-- Populates the fontstring and pairs the checkbutton with the randomly selected warrior table.
function setSundererText(fontString, chkBtn)
    local num = math.random(1, warriorTableCount);
    local playerName = warriorTable[num];
    warriorAuditTable[playerName] = chkBtn;
    fontString:SetText(playerName);
    SendChatMessage("!!---> !Sunder Boss! <---!!", "WHISPER", nil, GetUnitName(playerName))
    table.remove(warriorTable, num);
    warriorTableCount = warriorTableCount - 1;
end

-- Modifies the warriorTable variable and warriorTableCount
function getWarriorsInRaid()
    for i = 40, 1, -1 do
        name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i);
        if (name ~= nil and class == "Warrior" and role ~= "MAINTANK" and online) then
            table.insert(warriorTable, name);
            warriorTableCount = warriorTableCount + 1;
        end
    end
    -- For debug - keep in here because I don't want to look this ipairs func up again.
    -- for i,v in ipairs(warriorTable) do print(i,v) end
end
-- Monitors combat log to identify if any of the chosen sunderers performed their duty - if they do, checkbox is selected.
function Combat_OnEvent(self, event, ...)
    if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
        local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellId, spellName, spellSchool = CombatLogGetCurrentEventInfo();
        if (spellName == "Sunder Armor" and subevent == "SPELL_CAST_SUCCESS" and warriorAuditTable[sourceName] ~= nil) then
            warriorAuditTable[sourceName]:SetChecked(true);
        end
    end
end
