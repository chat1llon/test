local StaticData = {}

local datas = GMethod.execute("data.alldatas")
--need to do some crypto's work here.

function StaticData.checkSum()
    return StaticData.datas==datas
end

--可以用两种方式访问数据
function StaticData.getData(...)
    local keys = {...}
    local ret = datas
    for i, key in ipairs(keys) do
        ret = ret[key]
        if not ret then
            return ret
        end
    end
    return ret
end

for k, v in pairs(datas) do
    StaticData[k] = v
end

function StaticData.setData(k, v)
    StaticData[k] = v
    datas[k] = v
end

return StaticData
