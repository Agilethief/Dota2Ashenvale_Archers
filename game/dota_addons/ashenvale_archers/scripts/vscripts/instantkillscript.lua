--[[ Test script to kill the hero instantly
]]

function kill(keys)

	
	keys.caster:ForceKill(true)
	print("SPACE")
	print("SPACE")
	print("SPACE")
	print("SPACE")
	print("SPACE")
	--hero.RespawnUnit()
	--checkKeys(keys)
	--thisEntity:AddAbillity("archer_recall")
end

function checkKeys(keys)
        for key, value in pairs(keys) do
                print (key,value)
                --checkType(value)
        end
end    
function checkType(stuff)
        if (type(stuff)=="table") then
                for k, v in pairs(stuff) do
                        print(k,v)
                        checkType(v)
                end
        end
end