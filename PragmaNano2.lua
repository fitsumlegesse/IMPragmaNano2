
-- Fitsum Legesse
-- Symetrix
-- 10/14/2020



--- Convert hex <-> string

function string.fromhex(str)
    return (str:gsub('..', function (cc)
        return string.char(tonumber(cc, 16))
    end))
end
function string.tohex(str)
    return (str:gsub('.', function (c)
        return string.format('%02X', string.byte(c))
    end))
end


--Unit/DSP Information 

NamedControl.SetText("UnitName",Device.LocalUnit.Name)
NamedControl.SetText("UnitIP",Device.LocalUnit.ControlIP)
print(Device.Offline)


function offStatus()
    if Device.Offline then
        NamedControl.SetValue("OfflineLED",  1)
    else
        NamedControl.SetValue("OfflineLED",  0)
    end
end


--TCP SOCKET Creation 

MyTCP = TcpSocket.New()
MyTCP:Connect("192.168.100.121", 99999)
MyTCP.ReconnectTimeout = 0


-- UDP SOCKETS Creation  

MyUdp1 = UdpSocket.New()
MyUdp1:Open("192.168.100.179", 48630)


MyUdp2 = UdpSocket.New()
MyUdp2:Open("192.168.100.179", 49630)


MyUdp3 = UdpSocket.New()
MyUdp3:Open("192.168.100.179", 30718)

--- Data handler waits and listens for the hardware to send data

function HandleData(socket, packet)
    if(packet.Data == nil) then
        print("Data is nil")
        return
    else

        incomingData = packet.Data
        -- print("Device is sending this to connect: " .. incomingData)

        -- if(incomingData == "?")then
        --     MyTCP:Send("Send Something")
        --     print("TCP Ack have been sent")
        --     print("Connected light is on")
        -- else
            faId  = string.sub (incomingData, 7, 7)
            faLvl = string.sub(incomingData, 9, 13)
            levelz = tonumber(faLvl)
        -- end
            if(levelz == nil) then
                -- print(faLvl)
                return
            end
            --When data is available, pass faId and levelz to the movefader function
            moveComposerFader(faId, levelz)
        
    end
    
    
end
    --handle data runs when data is sent to it 
    MyUdp1.Data = HandleData

function moveComposerFader()
  
    -- print("ID value: " .. "Fader".. faId .. " and the " .. "Fader's current position is: "..levelz)
    if(levelz == 0 and levelz < 7167) then
        NamedControl.SetValue("Fader"..faId,  0)
    elseif(levelz > 7170 and levelz < 25599) then
        NamedControl.SetValue("Fader"..faId,  1)
    elseif(levelz > 25599 and levelz < 32255  ) then
        NamedControl.SetValue("Fader"..faId,  2)
    elseif(levelz > 32767 and levelz < 39424 ) then
        NamedControl.SetValue("Fader"..faId,  3)
    elseif(levelz > 40960 and levelz < 45568) then
        NamedControl.SetValue("Fader"..faId,  4)
    elseif(levelz > 45568 and levelz < 49664) then
        NamedControl.SetValue("Fader"..faId,  5)
    elseif(levelz > 50176 and levelz < 54272) then
        NamedControl.SetValue("Fader"..faId,  6)
    elseif(levelz > 54272 and levelz < 58368) then
        NamedControl.SetValue("Fader"..faId,  7)
    elseif(levelz > 58368 and levelz < 61952) then
        NamedControl.SetValue("Fader"..faId,  8)
    elseif(levelz > 61952 and levelz < 64512) then
        NamedControl.SetValue("Fader"..faId,  9)
    elseif(levelz > 64512 and levelz == 65535) then
        NamedControl.SetValue("Fader"..faId, 10)
    end
end

---Button Function


-- Mute Button 
alreadyMuted = false 

function muteButtons()
    
   MuteStatus=NamedControl.GetValue("muteButton")
   if(MuteStatus == 1)then  

        if(alreadyMuted == false)then
            MyUdp1:Send("192.168.100.121", 10001,string.fromhex("4353203330303720300d0a"))
            MyUdp1:Send("192.168.100.121", 10001,string.fromhex("4353203330303620300d0a"))
            MyUdp1:Send("192.168.100.121", 10001,string.fromhex("4353203330303520300d0a"))
            MyUdp1:Send("192.168.100.121", 10001,string.fromhex("4353203330303420300d0a"))
            MyUdp1:Send("192.168.100.121", 10001,string.fromhex("4353203330303320300d0a"))
            MyUdp1:Send("192.168.100.121", 10001,string.fromhex("4353203330303220300d0a"))
            MyUdp1:Send("192.168.100.121", 10001,string.fromhex("4353203330303120300d0a"))
            MyUdp1:Send("192.168.100.121", 10001,string.fromhex("4353203330303020300d0a"))
            NamedControl.SetValue("Fader7",  0)
            NamedControl.SetValue("Fader6",  0)
            NamedControl.SetValue("Fader5",  0)
            NamedControl.SetValue("Fader4",  0)
            NamedControl.SetValue("Fader3",  0)
            NamedControl.SetValue("Fader2",  0)
            NamedControl.SetValue("Fader1",  0)
            NamedControl.SetValue("Fader0",  0)
            alreadyMuted = true
        else       
            alreadyMuted = false
            
        end
    else
        -- Do nothing
    end

end


-- Flash Unit 
function identPragma()
    
    IdentifyDevice = NamedControl.GetValue("IdentifyDevice")
    if IdentifyDevice == 1 then
        MyUdp1:Send("192.168.100.121", 10001,string.fromhex("23290d"))
    else
        --Do Nothing 
    end
    
end



dataSent = false
-- print(dataSent)

--Runner Functions 
function testYourFunctions()

   

end

function frequentRunner()
    identPragma()
    offStatus()
    muteButtons()
end

function infrequentRunner()
    
    
   
end

--Timers

MyTimer2 = Timer.New()

MyTimer2.EventHandler = frequentRunner

MyTimer2:Start(.25)


MyTimer1 = Timer.New()

MyTimer1.EventHandler = infrequentRunner

MyTimer1:Start(1)


MyTimer3 = Timer.New()

MyTimer3.EventHandler = testYourFunctions

MyTimer3:Start(.25)
