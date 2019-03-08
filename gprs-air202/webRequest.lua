require"socket"

module(...,package.seeall)

--[[
������Ϊ������
��������
1��ÿ��10���ӷ���һ��λ�ð�"loc data\r\n"����̨�����۷��ͳɹ�����ʧ�ܣ�5��󶼶Ͽ����ӣ�
2���յ���̨������ʱ����rcv�����д�ӡ����
����ʱ���Լ��ķ������������޸������PROT��ADDR��PORT��֧��������IP��ַ
]]

local ssub,schar,smatch,sbyte,slen = string.sub,string.char,string.match,string.byte,string.len
--����ʱ���Լ��ķ�����
local SCK_IDX,PROT,ADDR,PORT = 1,"TCP","www.lewei50.com",80
--linksta:���̨��socket����״̬
local linksta
--�Ƿ�ɹ����ӹ�������
local hasconnected
--���������һ��Ҳû�������Ϻ�̨�����������쳣����
--һ�����������ڵĶ�����������Ӻ�̨ʧ�ܣ��᳢���������������ΪRECONN_PERIOD�룬�������RECONN_MAX_CNT��
--���һ�����������ڶ�û�����ӳɹ�����ȴ�RECONN_CYCLE_PERIOD������·���һ����������
--�������RECONN_CYCLE_MAX_CNT�ε��������ڶ�û�����ӳɹ������������
local RECONN_MAX_CNT,RECONN_PERIOD,RECONN_CYCLE_MAX_CNT,RECONN_CYCLE_PERIOD = 3,25,1,120
--reconncnt:��ǰ���������ڣ��Ѿ������Ĵ���
--reconncyclecnt:�������ٸ��������ڣ���û�����ӳɹ�
--һ�����ӳɹ������Ḵλ���������
--conning:�Ƿ��ڳ�������
local reconncnt,reconncyclecnt,conning = 0,0

local sensorValueTable = {}
local validDev = false

--[[
��������print
����  ����ӡ�ӿڣ����ļ��е����д�ӡ�������testǰ׺
����  ����
����ֵ����
]]
local function print(...)
	_G.print("webRequest",...)
end


function appendSensorValue(sname,svalue)
     sensorValueTable[""..sname]=""..svalue
end



function sendSensorValue(sname,svalue)
     --�������ݱ�����ʽ
     PostData = "["
     for i,v in pairs(sensorValueTable) do 
          PostData = PostData .. "{\"Name\":\""..i.."\",\"Value\":\"" .. v .. "\"},"
          --print(i)
          --print(v) 
     end
     PostData = PostData .."{\"Name\":\""..sname.."\",\"Value\":\"" .. svalue .. "\"}"
     PostData = PostData .. "]"
     
     data = "POST /api/V1/gateway/UpdateSensorsBySN/"..misc.getimei().." HTTP/1.1\r\nHost: www.lewei50.com\r\nContent-Length: " .. string.len(PostData) .. "\r\n\r\n"..PostData .. "\r\n"
     if(validDev) then
     	--pins.set(false,pincfg.PIN24)
     	snd(data)
     end
     sensorValueTable = {}
     PostData = ""
end

--[[
��������snd
����  �����÷��ͽӿڷ�������
����  ��
        data�����͵����ݣ��ڷ��ͽ���¼�������ntfy�У��ḳֵ��item.data��
		para�����͵Ĳ������ڷ��ͽ���¼�������ntfy�У��ḳֵ��item.para�� 
����ֵ�����÷��ͽӿڵĽ�������������ݷ����Ƿ�ɹ��Ľ�������ݷ����Ƿ�ɹ��Ľ����ntfy�е�SEND�¼���֪ͨ����trueΪ�ɹ�������Ϊʧ��
]]
function snd(data,para)
	return socket.send(SCK_IDX,data,para)
end

--[[
��������locrpt
����  ������λ�ð����ݵ���̨
����  ���� 
����ֵ����
]]
function locrpt()
	print("locrpt",linksta)
	--if linksta then
	if(nvm.get("qrCode")~=nil)then
		data = "GET /api/v1/device/getbysn/"..misc.getimei().."?encode=gbk HTTP/1.1\r\nHost: www.lewei50.com\r\nAccept: */*\r\n\r\n"
    lcd.setText("info","����״̬...") 
	else
		data = "GET /api/v1/sn/info/"..misc.getimei().."?type=hex HTTP/1.1\r\nHost: www.lewei50.com\r\nAccept: */*\r\n\r\n"
		lcd.setText("info","��ȡ��ά��")
	end
		snd(data)
		--if not snd("loc data\r\n","LOCRPT")	then locrpt1cb({data="loc data\r\n",para="LOCRPT"},false) end	
	--end
end

--[[
��������locrptcb
����  ��λ�ð����ͽ������������ʱ����10���Ӻ��ٴη���λ�ð�2
����  ��  
        result�� bool���ͣ����ͽ�������Ƿ�ʱ��trueΪ�ɹ����߳�ʱ������Ϊʧ��
		item��table���ͣ�{data=,para=}����Ϣ�ش��Ĳ��������ݣ��������socket.sendʱ����ĵ�2���͵�3�������ֱ�Ϊdat��par����item={data=dat,para=par}
����ֵ����
]]
function locrptcb(item,result)
	print("locrptcb",linksta)
	--if linksta then
		--10�����ȥ�Ͽ�socket���ӣ���10�����������շ������·�������
		sys.timer_start(socket.disconnect,10000,SCK_IDX)
		sys.timer_start(locrpt,10000)
	--end
end

--[[
��������sndcb
����  ���������ݽ���¼��Ĵ���
����  ��  
        result�� bool���ͣ���Ϣ�¼������trueΪ�ɹ�������Ϊʧ��
		item��table���ͣ�{data=,para=}����Ϣ�ش��Ĳ��������ݣ��������socket.sendʱ����ĵ�2���͵�3�������ֱ�Ϊdat��par����item={data=dat,para=par}
����ֵ����
]]
local function sndcb(item,result)
	print("sndcb",item.para,result)
	if not item.para then return end
	if item.para=="LOCRPT" then
		locrptcb(item,result)
	end
	if not result then link.shut() end
end

--[[
��������reconn
����  ��������̨����
        һ�����������ڵĶ�����������Ӻ�̨ʧ�ܣ��᳢���������������ΪRECONN_PERIOD�룬�������RECONN_MAX_CNT��
        ���һ�����������ڶ�û�����ӳɹ�����ȴ�RECONN_CYCLE_PERIOD������·���һ����������
        �������RECONN_CYCLE_MAX_CNT�ε��������ڶ�û�����ӳɹ������������
����  ����
����ֵ����
]]
local function reconn()
	print("reconn",reconncnt,conning,reconncyclecnt)
	--conning��ʾ���ڳ������Ӻ�̨��һ��Ҫ�жϴ˱����������п��ܷ��𲻱�Ҫ������������reconncnt���ӣ�ʵ�ʵ�������������
	if conning then return end
	--һ�����������ڵ�����
	if reconncnt < RECONN_MAX_CNT then
		reconncnt = reconncnt+1
		lcd.setText("info","����"..reconncnt)
		link.shut()
		connect()
	--һ���������ڵ�������ʧ��
	else
		if reconncyclecnt >= RECONN_CYCLE_MAX_CNT then
			print("could not get QRCode,I give up")
			lcd.setText("info","��������")
			sys.restart("connect fail")
		end
		sys.timer_start(reconn,RECONN_CYCLE_PERIOD*1000)
		reconncnt,reconncyclecnt = 0,reconncyclecnt+1
	end
end

--[[
��������ntfy
����  ��socket״̬�Ĵ�����
����  ��
        idx��number���ͣ�socket.lua��ά����socket idx��������socket.connectʱ����ĵ�һ��������ͬ��������Ժ��Բ�����
        evt��string���ͣ���Ϣ�¼�����
		result�� bool���ͣ���Ϣ�¼������trueΪ�ɹ�������Ϊʧ��
		item��table���ͣ�{data=,para=}����Ϣ�ش��Ĳ��������ݣ�Ŀǰֻ����SEND���͵��¼����õ��˴˲������������socket.sendʱ����ĵ�2���͵�3�������ֱ�Ϊdat��par����item={data=dat,para=par}
����ֵ����
]]
function ntfy(idx,evt,result,item)
	print("ntfy",evt,result,item,hasconnected)
	--���ӽ��������socket.connect����첽�¼���
	if evt == "CONNECT" then
		conning = false
		--���ӳɹ�
		if result then
			reconncnt,reconncyclecnt,linksta = 0,0,true
			--ֹͣ������ʱ��
			sys.timer_stop(reconn)
			--�������һ�����ӳɹ�
			if not hasconnected then
				hasconnected = true
				--����λ�ð�����̨
				locrpt()
			end
		--����ʧ��
		else
			if not hasconnected then
				--5�������
				sys.timer_start(reconn,RECONN_PERIOD*1000)
			else				
				link.shut()
			end			
		end	
	--���ݷ��ͽ��������socket.send����첽�¼���
	elseif evt == "SEND" then
		if item then
			sndcb(item,result)
		end
	--���ӱ����Ͽ�
	elseif evt == "STATE" and result == "CLOSED" then
		linksta = false
		--�����Զ��幦�ܴ���
	--���������Ͽ�������link.shut����첽�¼���
	elseif evt == "STATE" and result == "SHUTED" then
		linksta = false
		--�����Զ��幦�ܴ���
	--���������Ͽ�������socket.disconnect����첽�¼���
	elseif evt == "DISCONNECT" then
		linksta = false
		--�����Զ��幦�ܴ���			
	end
	--����������
	if smatch((type(result)=="string") and result or "","ERROR") then
		--�Ͽ�������·�����¼���
		link.shut()
	end
end

--[[
��������rcv
����  ��socket�������ݵĴ�����
����  ��
        idx ��socket.lua��ά����socket idx��������socket.connectʱ����ĵ�һ��������ͬ��������Ժ��Բ�����
        data�����յ�������
����ֵ����
]]
function rcv(idx,fbStr)
	--lcd.setPic("wifiState",5)
	if(nvm.get("qrCode")~=nil) then
		if(string.find(fbStr,"Invalid device ID")~=nil) then
		      --wifi not set,but have qrcode file
		      --print("fail")
		      --require("qrCode")
		      lcd.setPage(2)
		      lcd.qrCodeDisp(nvm.get("qrCode"),tonumber(nvm.get("qrLength")))
		      lcd.setText("info","����ɺ�,�ֹ������豸")
		else
		      print("ok")
		      lcd.setPic("wifiState",5)
		      validDev = true
		      nameStr = string.match(fbStr,"\"name\":\".+\"typeName\":\"lw%-board")
		      if(nameStr ~= nil)then
			      dName = string.sub(nameStr,9,-23)
	          lcd.setText("info","")
	          if(dName ~= nil) then
	               lcd.setText("deviceName",dName)
	          end
	        end
	  end
	else
		if(string.find(fbStr,"Invalid SN")~=nil) then
		    lcd.setText("info","��Ч��ά��")
		else
		    qrCode = string.sub(string.match(fbStr,"QRCode\":\"%w+\""),10,-2)
		    qrLength = string.sub(string.match(fbStr,"QRLength\":%d+"),11,-1)
		    lcd.setText("info","У���ά��..")
		    print("Got:"..qrCode)
		    nvm.set("qrCode",qrCode)
		    nvm.set("qrLength",qrLength)
		    nvm.flush()
		    lcd.setText("info","��ȡ�ɹ�.")
		    sys.restart("Got QRCode")
		end
	end
	
	--pins.set(true,pincfg.PIN24)
end

--[[
��������connect
����  ����������̨�����������ӣ�
        ������������Ѿ�׼���ã���������Ӻ�̨��������������ᱻ���𣬵���������׼���������Զ�ȥ���Ӻ�̨
		ntfy��socket״̬�Ĵ�����
		rcv��socket�������ݵĴ�����
����  ����
����ֵ����
]]
function connect()
	socket.connect(SCK_IDX,PROT,ADDR,PORT,ntfy,rcv)
	conning = true
end

--connect()
