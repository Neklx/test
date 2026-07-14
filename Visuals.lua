-- ====================================================================================
-- NEVERLOSE.CC - MOVEMENT MODULE (Movement.lua)
-- ====================================================================================

local UserInputService = game:GetService("UserInputService")
local Movement = {
    BhopEnabled = true,
}

local CharacterController = nil

-- Extracts CharacterController securely from active upvalues
local function findCharacterController()
    if typeof(getgc) ~= "function" then return nil end
    for _, v in ipairs(getgc(true)) do
        if typeof(v) == "table" and rawget(v, "getCurrentCharacter") and rawget(v, "jump") then
            return v
        end
    end
    return nil
end

function Movement:Initialize()
    task.spawn(function()
        while not CharacterController do
            CharacterController = findCharacterController()
            task.wait(1)
        end
    end)
end

-- Invoked continuously inside the master render step thread
function Movement:ProcessBhop()
    if not self.BhopEnabled or not CharacterController then return end
    
    -- Check if the jump key is held down
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        local activeChar = CharacterController.getCurrentCharacter()
        
        -- If character is active, grounded, and ready to jump
        if activeChar and activeChar.IsGrounded then
            activeChar.IsJumpRequested = true
            activeChar:Jump()
        end
    end
end

return Movement
