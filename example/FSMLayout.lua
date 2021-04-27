-- @author: yangfch3
-- @date: 2021/04/27 14:06
------------------------------------------
-- 状态机配置文件

local ST = require "StateTransfer"

local STKeyDict = {
    init_enter = "init_enter",
    login_try = "login_try",
    login_result = "login_result",
    storage_pull = "storage_pull",
    restart_done = "restart_done"
}

local DictState = {
    Game = require "State",
    Login = require "State",
    Restart = require "State"
}

local StateTransferLayout = {
    { from = "Any", st = ST.st({ [STKeyDict.init_enter] = ST.trigger() }), to = "Game" },

    { from = "Game", st = ST.st({ [STKeyDict.login_try] = ST.trigger() }), to = "Login" },

    { from = "Login", st = ST.st({ [STKeyDict.login_result] = ST.trigger() }), to = "Game" },

    { from = "Game", st = ST.st({ [STKeyDict.storage_pull] = ST.trigger() }), to = "Restart" },

    { from = "Restart", st = ST.st({ [STKeyDict.restart_done] = ST.trigger() }), to = "Game" }
}

return {
    STKeyDict = STKeyDict,
    DictState = DictState,
    StateTransferLayout = StateTransferLayout
}
