local tArgs = {...}
local username = "Guest"..math.random(0,10000)
if tArgs[1] ~= nil and type(tArgs[1]) == "string" then
  username = tArgs[1]
end
local version = "beta v1.5"
os.loadAPI(".chat/net")
net.disablelog()
local mx, my = term.getSize()
local server = "chat.nothy.se:1337"
local serverList = {
  id = {
    address = "",
    name = "If you see this, something went wrong.",
    official = false
  },
  id2 = {
    address = "ERROR",
    name = "Like, geez.",
    official = false
  },

}
if tArgs[2] ~= nil and type(tArgs[2]) == "string" then
  server = tArgs[2]
end
local msgs = {}
local msg = ""
local menu = "serverlist"
local connected = false
local history = {}
local typing = false
local attempt = 1
local status = "Connecting.."
local select = 1
local mx, my = term.getSize()
function getMessages()
  local msgs_bak = net.getMessages(server, username)
  if msgs_bak == nil then
    term.setTextColor(colors.red)
    attempt = attempt + 1
    term.setTextColor(colors.white)
    if attempt >= 3 then error("Could not connect to "..server) end
  else
    msgs = msgs_bak
    status = server
  end
end
function getServerList()
  serverList = net.getServerList(server, username)
  if serverList == nil then
    error("Could not connect to "..server)
  else
    serverList[#serverList+1] = {
      address = "::",
      name = "Other...",
      official = false
    }
  end
end
function textField(y)
  term.setCursorPos(1,y)
  term.setTextColor(colors.lightBlue)
  term.setBackgroundColor(colors.white)
  term.clearLine()
  write("> ")
  term.setTextColor(colors.gray)
  term.setCursorPos(3,y)
  input = read(nil, history)

  return input
end
function draw()
  term.setBackgroundColor(colors.black)
  term.setTextColor(colors.white)

  if menu == "chat" then
    term.clear()
    term.setCursorPos(1,1)
    for k,v in pairs(msgs) do
      write("<")
      term.setTextColor(v.color)
      write(v.usr)
      term.setTextColor(colors.white)
      write(">: ")
      term.setTextColor(tonumber(v.msgcolor))
      print(v.message)
      term.setTextColor(colors.white)
      local cx, cy = term.getCursorPos()
      if cy >= 17 then
        term.scroll(1)
      end
    end
    term.setCursorPos(1,my-1)
    term.setTextColor(colors.lightBlue)
    write("> ")
    term.setTextColor(colors.white)
    term.setCursorPos(1,my)
    term.setTextColor(colors.gray)
    write(""..username.." | "..status.." | "..version)
    term.setTextColor(colors.white)
  end
  if menu == "serverlist" then
    term.clear()
    term.setCursorPos(1,1)
    for k,v in pairs(serverList) do

      if select == k then
        term.setTextColor(colors.lightGray)
        write(">")
        term.setTextColor(colors.white)
      end
      if k ~= #serverList then
        if v.official then
          if select ~= k then
            term.setTextColor(colors.yellow)
            write(" [OFFICIAL] ")
          else
            term.setTextColor(colors.yellow)
            write("[OFFICIAL] ")
          end

        else
          if select ~= k then
            write(" ")
          else
            write("")
          end
        end
        term.setTextColor(colors.white)
        print(v.name.." ("..v.address..")")
        if v.official then
          term.setTextColor(colors.gray)
          print(string.rep("-",mx))
          term.setTextColor(colors.white)
        else
          print(string.rep(" ",mx))
        end


      else
        if select ~= k then
          term.setTextColor(colors.lightGray)
          print(" "..v.name)
        else
          term.setTextColor(colors.lightGray)
          print(v.name)
        end

      end
    end
  end

end
function message()
  if menu == "chat" then
    typing = true
    term.setCursorPos(1,my-1)
    term.setTextColor(colors.lightBlue)
    term.setBackgroundColor(colors.white)
    term.clearLine()
    write("> ")
    term.setTextColor(colors.gray)
    term.setCursorPos(3,my-1)
    msg = read(nil, history)
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    term.clearLine()
    term.setCursorPos(3,my-1)
    term.setTextColor(colors.lightBlue)
    write("> ")

    typing = false
    if string.find(msg,"/",1) == 1 then
      if msg == "/exit" then
        net.send(server,"Goodbye!",username,colors.lightGray)
        shell.exit()
      end
    else
      if string.len(msg) > 1 and string.len(msg) < 256 then
        net.send(server,msg,username)
      else
        if string.len(msg) >= 256 then
          term.setBackgroundColor(colors.red)
          term.setCursorPos(1,my-1)
          term.clearLine()
          sleep(0.25)
          term.setBackgroundColor(colors.black)
          term.clearLine()
          term.setCursorPos(3,my-1)
          term.setTextColor(colors.lightBlue)
          write("> ")
        end
      end
    end
  end

end
function clicks()
  local t = os.startTimer(10)
  draw()
  while(true) do
    local event, button, x, y = os.pullEvent()
    if menu == "chat" then
      if event == "key" and button == keys.enter then
        draw()
        message()
      end
      if event == "key" and button == keys.home then
        menu = "serverlist"
        draw()
      end
      if event == "mouse_click" and x >= 1 and x <= 46 and y == my-1 then
        draw()
        message()
      end
      if event == "timer" and button == t then
        getMessages()
      end

    end
    if menu == "serverlist" then
      if event == "key" and button == keys.up then

        if select > 1 then
          select = select - 1
        end
        draw()
      end
      if event == "key" and button == keys.down then
        if select < #serverList then
          select = select + 1
        end
        draw()
      end
      if event == "key" and button == keys.enter then
        if select ~= #serverList then
          server = serverList[select].address
          menu = "chat"
        else
          server = textField(my-3)
          menu = "chat"
        end
        term.setTextColor(colors.gray)
        term.setBackgroundColor(colors.black)
        term.setCursorPos(2, my-1)
        write("Connecting... Please be patient")
      end
      if event == "key" and button == keys.home then
        shell.exit()
      end
    end

  end
end
function timer()
  t = os.startTimer(10)
  while(true) do
    local event, tid = os.pullEvent("timer")
    if event == "timer" and tid == t and not typing then
      t = os.startTimer(10)
      getMessages()
      draw()
    end
  end

end
function update()

end
shell.run("clear")
getServerList()
parallel.waitForAny(clicks, timer)
print("Thanks for using chatter!")
