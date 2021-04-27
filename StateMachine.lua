-- @author: yangfch3
-- @date: 2021/04/27 11:06
------------------------------------------
local StateMachine = BaseClass("StateMachine")

function StateMachine:ctor(fsmName, config, isCacheState)
    self._state_machine_name = fsmName

    self._dict_states = config.DictState                    -- StateName -> StateClass
    self._dict_state_cache = {}                             -- State 缓存的对象 Map
    self._cur_state = nil
    self._cur_state_name = "Any"
    self._is_cache_state = isCacheState                     -- 是否缓存各个 State

    self._dict_transfer = {}                                -- 结构 {AName = {BName = st}}
    self._dict_transfer_data = {}                           -- 各个 st
    self._transfer_dirty = false                            -- transfer 数据是否为脏，是否要重新运行 Transfer 判断逻辑

    self:LayoutTransfer(config.StateTransferLayout)
end

-- 批量设置各个 Transfer 的判断数据
function StateMachine:SetValueDict(dict, apply)
    for k, v in pairs(dict) do
        self:SetValue(k, v, false)
    end

    if apply then
        self:StateTransfer()
    end
end

-- Trigger 类型的 Transfer 设置
function StateMachine:SetTrigger(key)
    print("StateMachine: SetTrigger - " .. key)
    self._dict_transfer_data[key] = true
    self._transfer_dirty = true
    self:StateTransfer()
    self._dict_transfer_data[key] = false
end

-- 设置 Transfer 判断用到的值
function StateMachine:SetValue(key, value, forceApply)
    self._dict_transfer_data[key] = value
    self._transfer_dirty = true

    if forceApply then
        self:StateTransfer()
    end
end

-- 关闭状态机
function StateMachine:PowerOff()
    if self._cur_state then
        self._cur_state:LeaveState()
        self._cur_state = nil
        self._cur_state_name = "Any"
    end
end

----------------- ↑ 以上为核心对外方法 ---------------------

function StateMachine:LayoutTransfer(layout)
    for _, transfer in ipairs(layout) do
        self:AddTransfer(transfer.from, transfer.st, transfer.to)
    end
end

function StateMachine:AddTransfer(from, st, to)
    local dict_trans = self._dict_transfer[from] or {}
    self._dict_transfer[from] = dict_trans

    assert(from ~= to)
    if dict_trans[to] then
        error("StateMachine:AddTransfer: exist state transfer " .. from .. "->" .. to)
    end
    dict_trans[to] = st
end

-- 执行状态转移
function StateMachine:EvalTransfer(from)
    local dict_trans = self._dict_transfer[from]
    if dict_trans then
        for to, st in pairs(dict_trans) do
            if st(self._dict_transfer_data) then
                print("StateMachine:EvalTransfer - from " .. from .. " to " .. to)
                self:ChangeStateByName(to)
                break
            end
        end
    end
end

function StateMachine:StateTransfer()
    if not self._transfer_dirty then
        return
    end

    self:EvalTransfer(self._cur_state_name)

    self._transfer_dirty = false
end

function StateMachine:ChangeState(state, ...)
    if self._cur_state == state then
        if self._cur_state then
            self._cur_state:UpdateState()
        end
        return
    end

    if self._cur_state then
        self._cur_state:LeaveState(state)
    end

    local prev_state = self._cur_state
    self._cur_state = state or self._default_state

    if self._cur_state then
        self._cur_state:ResetState()
        self._cur_state:EnterState(prev_state)
    end
end

function StateMachine:ChangeStateByName(stateName, ...)
    local state = self:FindState(stateName)
    if state == nil then
        error("StateMachine:ChangeStateByName - cannot find state " .. stateName)
    end

    self:ChangeState(state)
    self._cur_state_name = stateName

    return self._cur_state
end

function StateMachine:CreateState(stateName)
    local StateClass = self._dict_states[stateName]
    return StateClass.New(self, stateName)
end

function StateMachine:FindState(stateName)
    local state =  self._dict_state_cache[stateName]
    if state ~= nil then
        return state
    end

    state = self:CreateState(stateName)

    if self._is_cache_state then
        self._dict_state_cache[stateName] = state
    end
    return state
end

return StateMachine
