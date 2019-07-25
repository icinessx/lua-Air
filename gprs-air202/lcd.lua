module(...,package.seeall)

--[[
��������
����LCD��Ļ����ʾ����
]]

local LCD_UART_ID = 1
local currentPage = 0
local pageLock = false
local testDot = false
local bEnableRefresh = true
local dName = ""
local wifiState=4

function setDevName(devName)
	dName = devName
end

function getCurrentPage()
	return currentPage
end

function disableRefresh()
	bEnableRefresh = false
end

function enableRefresh()
	bEnableRefresh = true
end

--֡ͷ�����Լ�֡β
local CMD_SCANNER,CMD_GPIO,CMD_PORT,FRM_TAIL = 1,2,3,string.char(0xC0)
--���ڶ��������ݻ�����
local rdbuf = ""

--[[
��������print
����  ����ӡ�ӿڣ����ļ��е����д�ӡ�������testǰ׺
����  ����
����ֵ����
]]
local function print(...)
	_G.print("[LCD]",...)
end

function showPage(pid)
     if(currentPage ~= pid) then
          write("page "..pid)
          write("page "..pid)
          currentPage= pid
     end
end

function refreshPage()
	print("refresh page")
	if(Sensors.data()["Hum"]) then pg = 1 end
	if(Sensors.data()["HCHO"]) then pg = 4 end
	if(Sensors.data()["CO2"]) then
	    if(pg==4) then
	    --co2 + hcho
	         pg = 6
	    else
	    --co2 only
	         pg = 5
	    end
	end
	showPage(pg)
	setPic("wifiState",wifiState)
	setText("deviceName",dName)
	htStr = ""
	pmStr = " "
	hchoStr = " "
	co2Str = " "
	for k,v in pairs(Sensors.data()) do
	    print(k,v,Sensors.units()[k])
	    if(k=="Hum")then
	    	setText("hum",v..Sensors.units()[k])
	    	htStr = htStr .. "H:"..v.."%"
	    end
	    if(k=="Temp")then
	    	setText("temp",v..Sensors.units()[k])
	    	htStr = "T:"..v.."C "..htStr
	    end
	    if(k=="pm25")then
	    	setText("pm25",v..Sensors.units()[k])
	    	pmStr = " PM:"..v..Sensors.units()[k]
	    end
	    if(k=="aqi")then
	    	setText("aqi",v..Sensors.units()[k])
	    	pmStr = "AQI:"..v..Sensors.units()[k]..pmStr
	    end
	    if(k=="HCHO")then
	    	setText("HCHO",v..Sensors.units()[k])
	    	hchoStr ="HCHO:"..v..Sensors.units()[k]
	    end
	    if(k=="CO2")then
	    	setText("CO2",v..Sensors.units()[k])
	    	co2Str ="CO2:"..v..Sensors.units()[k]
	    end
	end
	oledShow(htStr,pmStr,hchoStr,co2Str)
	print("htStr,pmStr,hchoStr,co2Str")
	print(htStr,pmStr,hchoStr,co2Str)
end

--[[
��������read
����  ����ȡ���ڽ��յ�������
����  ����
����ֵ����
]]
local function read()
	
end

--[[
��������write
����  ��ͨ�����ڷ�������
����  ��
		s��Ҫ���͵�����
����ֵ����
]]
function write(s)
	if(bEnableRefresh == true) then
		print("write",s)
		uart.write(LCD_UART_ID,s..string.char(255)..string.char(255)..string.char(255))
	end
end

function setPage(id)
	if(pageLock == false)then
		write("page "..id)
		write("page "..id)
		currentPage = id
	end
end

function lockPage(state)
	pageLock = state
end

function setInfo(cnt)
	write("info.txt=\""..cnt.."\"")
end

function displayTestDot()
	if(testDot == false) then
		setInfo(".")
		testDot = true
	else
		setInfo("")
		testDot = false
	end
end

function setText(textName,txt)
     write(textName..".txt=\""..txt.."\"")
end

function setNumber(numName,num)
     write(numName..".val="..num)
end

function setPic(numName,num)
     write(numName..".pic="..num)
end



function drawRec(startPos,endPos,size,bFill)
     startPosX = 45--37
     startPosY = 41--33
     if(bFill==0) then
     write("fill "..startPos*size+startPosX..","..endPos*size+startPosY..","..size..","..size..",WHITE"..string.char(255)..string.char(255)..string.char(255))
     end
end

function qrCodeDisp(qrCode,qrLength)
	lockPage(true)
	setPage(2)
	write("fill 33,29,170,170,BLACK"..string.char(255)..string.char(255)..string.char(255))
	local h2b = {
	    ["0"] = 0,
	    ["1"] = 1,
	    ["2"] = 2,
	    ["3"] = 3,
	    ["4"] = 4,
	    ["5"] = 5,
	    ["6"] = 6,
	    ["7"] = 7,
	    ["8"] = 8,
	    ["9"] = 9,
	    ["A"] = 10,
	    ["B"] = 11,
	    ["C"] = 12,
	    ["D"] = 13,
	    ["E"] = 14,
	    ["F"] = 15
	}
	print(string.len(qrCode))
	if(qrLength == 841)then
		row = 29
	end
	count = 1
	currentRow = 0
	currentCol = 0
	for currentBlock = 1,string.len(qrCode),1 do
		currentChar = string.sub(qrCode,currentBlock,currentBlock)
		--print(currentBlock,currentChar,h2b[string.upper(currentChar)])
		--output = ""
		currentNum = h2b[string.upper(currentChar)]
		bitMask = 8
		repeat
			--bit.band(currentNum,bitMask)/bitMask is what we needed
			--output = output .. bit.band(currentNum,bitMask)/bitMask
			currentColor = bit.band(currentNum,bitMask)/bitMask
			drawRec(currentCol,currentRow,5,currentColor)
			count = count + 1
			currentRow = currentRow + 1
			if(currentRow == row) then
				currentRow = 0
				currentCol = currentCol + 1
			end
			bitMask = bitMask/2
			if(count > qrLength) then
				break
			end
		until bitMask < 1
		--print(output)
	end
end

-- ��ȡ�ַ�����ʾ����ʼX����
local function getxpos(width, str)
    return (width - string.len(str) * 8) / 2
end

function oledShow(str, str2, str3, str4)
    local WIDTH, HEIGHT = disp.getlcdinfo()
    disp.clear()
    disp.puttext(common.utf8ToGb2312(str), getxpos(WIDTH, common.utf8ToGb2312(str)), 0)
    if str2 ~= nil then disp.puttext(common.utf8ToGb2312(str2), getxpos(WIDTH, common.utf8ToGb2312(str2)), 16) end
    if str3 ~= nil then disp.puttext(common.utf8ToGb2312(str3), getxpos(WIDTH, common.utf8ToGb2312(str3)), 32) end
    if str4 ~= nil then disp.puttext(common.utf8ToGb2312(str4), getxpos(WIDTH, common.utf8ToGb2312(str4)), 48) end
    --ˢ��LCD��ʾ��������LCD��Ļ��
    disp.update()
end


--����ϵͳ���ڻ���״̬���˴�ֻ��Ϊ�˲�����Ҫ�����Դ�ģ��û�еط�����pm.sleep("test")���ߣ��������͹�������״̬
--�ڿ�����Ҫ�󹦺ĵ͡�����Ŀʱ��һ��Ҫ��취��֤pm.wake("test")���ڲ���Ҫ����ʱ����pm.sleep("test")
--pm.wake("test")
--ע�ᴮ�ڵ����ݽ��պ����������յ����ݺ󣬻����жϷ�ʽ������read�ӿڶ�ȡ����
--sys.reguart(LCD_UART_ID,read)
--���ò��Ҵ򿪴���

--uart.setup(LCD_UART_ID,9600,8,uart.PAR_NONE,uart.STOP_1)
