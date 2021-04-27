function BaseClass(classname, super)
    local cls

    if super then
        cls = {}
        setmetatable(cls, {__index = super})
        cls.super = super
    else
        cls = {ctor = function() end}
    end

    cls.__cname = classname
    cls.__index = cls

    function cls.New(...)
        local instance = setmetatable({}, cls)
        instance.class = cls

        -- 调用初始化方法
		do
			local create
			create = function(c, ...)
				if c.super then
					create(c.super, ...)
				end
				if c.ctor then
					c.ctor(instance, ...)
				end
			end

			create(cls, ...)
		end

        return instance
    end

    return cls
end
