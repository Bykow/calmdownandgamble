

-- Declare the new addon and load the libraries we want to use -- 
CalmDownandGamble = LibStub("AceAddon-3.0"):NewAddon(
    "CalmDownandGamble", "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0"
)

-- Basic Adddon Initialization stuff, virtually inherited functions -- 
-- ================================================================ -- 

-- CONSTRUCTOR -- 
function CalmDownandGamble:OnInitialize()
    -- Set up a database so we can save results -- 
    self.db = LibStub("AceDB-3.0"):New("CalmDownandGambleDB")
	self:RegisterCDCallbacks()
end

-- INIT FOR ENABLE -- 
function CalmDownandGamble:OnEnable()
    
	

end

-- DESTRUCTOR -- 
function CalmDownandGamble:OnDisable()
end


-- Some Util functions to clean up life -- 
-- =================================== -- 
function CalmDownandGamble:RegisterCDCallbacks()

end

CalmDownandGamble:RegisterEvent("CHAT_MSG_ADDON")
CalmDownandGamble:RegisterEvent("CHAT_MSG_CHANNEL")
CalmDownandGamble:RegisterChatCommand("cdgroll", "GenerateRoll")
CalmDownandGamble:RegisterChatCommand("cdgjoin", "JoinGame")
CalmDownandGamble:RegisterChatCommand("cdgleave", "LeaveGame")

-- Corresponding Chat command funcs -- 
function CalmDownandGamble:GenerateRoll()
end

function CalmDownandGamble:JoinGame()
	CrossGambling_Frame:Show();
end

function CalmDownandGamble:LeaveGame()
end














