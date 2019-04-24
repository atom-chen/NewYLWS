--时间处理相关逻辑

local string_format = string.format
local math_floor = math.floor

local TimeUtil = {}

--转换格式:xx年xx月xx日 xx:xx:xx
--format_id:自定义的转换格式("传Language的id,为nil时使用默认的格式")
function ToYearMonthDayHourMinSec(time_stamp, format_id, isShowYear, time_zone)
    local timeData 
    if time_zone then
        timeData = os.date("!*t", time_stamp)
    else
        timeData = os.date("*t", time_stamp)
    end
    local year = timeData["year"]
    local month = timeData["month"]
    local day = timeData["day"]
    local hour = timeData["hour"]
    if time_zone then
        hour = hour + time_zone
    end
    local min = timeData["min"]
    local sec = timeData["sec"]

    if isShowYear == nil then
        isShowYear = true
    end
    if not format_id then
        format_id = isShowYear and 51 or 67
    end
    local timeStr = nil
    if isShowYear then
        timeStr = string_format(Language.GetString(format_id), year, month, day, hour, min, sec)
    else
        timeStr = string_format(Language.GetString(format_id), month, day, hour, min, sec)
    end
    return timeStr
end

--转换格式: xx:xx:xx
--format_id:自定义的转换格式("传Language的id,为nil时使用默认的格式")
function ToHourMinSec(time_stamp, format_id, time_zone)
    local timeData 
    if time_zone then
        timeData = os.date("!*t", time_stamp)
    else
        timeData = os.date("*t", time_stamp)
    end
    local hour = timeData["hour"]
    if time_zone then
        hour = hour + time_zone
    end
    local min = timeData["min"]
    local sec = timeData["sec"]

    format_id = format_id or 66
    local timeStr = string_format(Language.GetString(format_id), hour, min, sec)
    return timeStr
end

function GetTimePassStr(time_stamp, showMin)
    if showMin == nil then 
        showMin = false
    end

    local day_second = 24 * 60 * 60
    local hour_second = 60 * 60

    local time = Player:GetInstance():GetServerTime() - time_stamp
    if time > 30 * day_second then
        return Language.GetString(70)
    end

    if time > 7 * day_second then
        return Language.GetString(71)

    elseif time > day_second then
        return string_format(Language.GetString(72), math_floor(time / day_second))

    elseif time > hour_second then
        return string_format(Language.GetString(73), math_floor(time / hour_second))

    else
        if showMin then --x分钟 or 刚刚
            return time > 60 and string_format(Language.GetString(74), math_floor(time / 60)) or Language.GetString(76)
        else
            if time > 30 * 60 then
                return Language.GetString(75)
            else
                return Language.GetString(76)
            end
        end
    end
end

--n为秒数
function ToMinSecStr(n, strID)
    local t = n
    local m = math_floor(t / 60)
    local s = math_floor(t % 60)
    local str = ''

    if strID then
        return string_format(Language.GetString(strID), m, s)
    else
        str = m < 10 and '0'..m or m..''
        str = str..':'
        str = str..(s < 10 and '0'..s or s)
        return str
    end
end

function ToHourMinSecStr(n, strID)
    local t = n

    local hour_second = 60 * 60
    local hour = math_floor(t / hour_second)
    local min = math_floor(t % hour_second / 60)
    local sec = math_floor(t % 60)

    if strID then
        return string_format(Language.GetString(strID), hour, min, sec)
    end

    local str = ''
    str = hour < 10 and '0'..hour or hour..'' 
    str = str..':'..ToMinSecStr(t % hour_second)
    return str
end

function GetTodayCrossDayTimeStamp()
    local timeData = os.date("*t", os.time())
    local _year = timeData["year"]
    local _month = timeData["month"]
    local _day = timeData["day"]
    local _hour = 0
    local _min = 0
    local _sec = 0
    local timeStamp = os.time({year = _year, month = _month, day = _day, hour = _hour, minute = _min, second = _sec})
    return timeStamp
end

function GetTime(time_stamp, time_zone)
    local timeData 
    if time_zone then
        timeData = os.date("!*t", time_stamp)
        timeData.hour = timeData.hour + time_zone
        time_stamp = os.time(timeData)
        timeData = os.date("*t", time_stamp)
    else
        timeData = os.date("*t", time_stamp)
    end
    return timeData
    --return os.date("*t", time_stamp)
end

TimeUtil.ToYearMonthDayHourMinSec = ToYearMonthDayHourMinSec
TimeUtil.ToHourMinSec = ToHourMinSec
TimeUtil.ToHourMinSecStr = ToHourMinSecStr
TimeUtil.GetTimePassStr = GetTimePassStr
TimeUtil.ToMinSecStr = ToMinSecStr
TimeUtil.GetTodayCrossDayTimeStamp = GetTodayCrossDayTimeStamp
TimeUtil.GetTime = GetTime

return TimeUtil