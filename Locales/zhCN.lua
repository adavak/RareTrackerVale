-- The locale for the Chinese language, provided generously by cikichen.
local L = LibStub("AceLocale-3.0"):NewLocale("RareTrackerVale", "zhCN")
if not L then return end

-- Option menu strings.
L["Rare window scale"] = "稀有窗口缩放"
-- L["Set the scale of the rare window."] = ""
L["Disable All"] = "禁用全部"
-- L["Disable all non-favorite rares in the list."] = ""
L["Enable All"] = "启用全部"
-- L["Enable all rares in the list."] = ""
L["Reset Favorites"] = "重置偏好"
L["Reset the list of favorite rares."] = ""
-- L["General Options"] = ""
-- L["Rare List Options"] = ""
-- L["Active Rares"] = ""

-- Status messages.
L["<%s> Moving to shard "] = "<%s> 移动到分片 "
L["<%s> Failed to register AddonPrefix '%s'. %s will not function properly."] = "<%s> 无法注册插件前缀 '%s'. %s无法正常运行."