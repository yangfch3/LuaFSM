-- @author: yangfch3
-- @date: 2021/04/27 11:06
------------------------------------------
local State = BaseClass("State")

function State:ctor(fsm, stateName)
    self._fsm = fsm
    self._state_name = stateName

    self:OnCtor()
end

function State:OnCtor()

end

function State:ResetState()

end

function State:EnterState(prevState)

end

function State:LeaveState(nextState)

end

function State:UpdateState()

end

return State
