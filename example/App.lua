-- 这是你的 Game 逻辑

require "BaseClass"

local FSMConfig = require "example/FSMLayout"
local StateMachine = require "StateMachine"

local fsm = StateMachine.New("APP_STAGE_FSM", FSMConfig, true)

fsm:SetTrigger(FSMConfig.STKeyDict.init_enter)
fsm:SetTrigger(FSMConfig.STKeyDict.login_try)
fsm:SetTrigger(FSMConfig.STKeyDict.login_result)
fsm:SetTrigger(FSMConfig.STKeyDict.storage_pull)
fsm:SetTrigger(FSMConfig.STKeyDict.restart_done)

