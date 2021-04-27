-- 状态转换条件 Hub
-- @author: yangfch3
-- @date: 2021/04/27 11:06
------------------------------------------
-- 条件判断函数
-- 传入一个基准值，返回一个利用运行值基准值进行判断的函数
-- 基准值 - 在创建 Layout 里的 ST 时传入
-- 运行值 - 在 StateMachine 里调用 ST 判断时传入
local function equal(a, def)
    assert(a ~= nil)
    return function(b)
        return a == b
    end
end

local function less(a, def)
    assert(a ~= nil)
    return function(b)
        b = b or def or 0
        return b < a
    end
end

local function eLess(a, def)
    assert(a ~= nil)
    return function(b)
        b = b or def or 0
        return b <= a
    end
end

local function above(a, def)
    assert(a ~= nil)
    return function(b)
        b = b or def or 0
        return b > a
    end
end

local function eAbove(a, def)
    assert(a ~= nil)
    return function(b)
        b = b or def or 0
        return b >= a
    end
end

local function is_true()
    return equal(true, false)
end

local function is_false()
    return equal(false, true)
end

local function trigger()
    return equal(true, false)
end

--- State Transfer 包装方法
local function st_and(condList)
    return function(dictTransfer)
        for name, cond in ipairs(condList) do
            local pass = cond(dictTransfer[name], dictTransfer)
            if not pass then
                print("cond failed", name)
                return false
            end
        end

        return true
    end
end

local function st_or(condList)
    return function(dictTransfer)
        for name, cond in ipairs(condList) do
            local pass = cond(dictTransfer[name])
            if pass then
                return true
            end
        end

        return false
    end
end

local function st_not(condList)
    return function(dictTransfer)
        for name, cond in ipairs(condList) do
            local pass = cond(dictTransfer[name])
            if pass then
                print("cond failed", name)
                return false
            end
        end

        return true
    end
end

local function st(cond)
    local name, func = next(cond)
    return function(dictTransfer)
        return func(dictTransfer[name])
    end
end

return {
    equal = equal,
    less = less,
    eLess = eLess,
    above = above,
    eAbove = eAbove,
    is_true = is_true,
    is_false = is_false,
    trigger = trigger,

    st_and = st_and,
    st_or = st_or,
    st_not = st_not,
    st = st,
}
