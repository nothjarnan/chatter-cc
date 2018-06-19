local tArgs = {...}
local username = "Guest"..math.random(0,10000)
if tArgs[1] ~= nil and type(tArgs[1]) == "string" then
  username = tArgs[1]
end

os.loadAPI(".chat/net")
net.disablelog()
local mx, my = term.getSize()
local server = "localhost:6789"
if tArgs[2] ~= nil and type(tArgs[2]) == "string" then
  server = tArgs[2]
end
local msgs = {}
local msg = ""
local connected = false
local history = {}
local typing = false
function getMessages()
  local msgs_bak = net.getMessages(server, username)
  if msgs_bak == nil then
    term.setTextColor(colors.red)
    print("Connection lost, reconnecting..")
    term.setTextColor(colors.white)
  else
    connected = true
    msgs = msgs_bak
  end
end

function draw()
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
  term.setCursorPos(1,18)
  term.setTextColor(colors.lightBlue)
  write("> ")
  term.setTextColor(colors.white)
  term.setCursorPos(1,19)
  term.setTextColor(colors.gray)
  write(""..username.." | "..server)
  term.setTextColor(colors.white)
end

function clicks()
  local t = os.startTimer(10)
  while(true) do
    getMessages()
    draw()
    local event, button, x, y = os.pullEvent("mouse_click")
    if x >= 1 and x <= 46 and y == 18 then
      typing = true
      term.setCursorPos(1,18)
      term.setTextColor(colors.lightBlue)
      term.setBackgroundColor(colors.white)
      term.clearLine()
      write("> ")
      term.setTextColor(colors.gray)
      term.setCursorPos(3,18)
      msg = read(nil, history)
      term.setBackgroundColor(colors.black)
      term.setTextColor(colors.white)
      term.clearLine()
      term.setCursorPos(3,18)
      term.setTextColor(colors.lightBlue)
      write("> ")

      typing = false
      if string.find(msg,"/",1) == 1 then
        if msg == "/exit" then
          net.send(server,"Goodbye!",username,colors.lightGray)
          break
        end
      else
        if string.len(msg) > 1 and string.len(msg) < 256 then
          net.send(server,msg,username)
        else
          if string.len(msg) >= 256 then
            term.setBackgroundColor(colors.red)
            term.setCursorPos(1,18)
            term.clearLine()
            sleep(0.25)
            term.setBackgroundColor(colors.black)
            term.clearLine()
            term.setCursorPos(3,18)
            term.setTextColor(colors.lightBlue)
            write("> ")
          end
        end
      end
    end
  end
end
function timer()
  while(true) do
    local event, button, x, y = os.pullEvent()
    if event == "timer" and button == t and not typing then
      t = os.startTimer(2)
      getMessages()
      draw()
    end
  end

end
shell.run("clear")
parallel.waitForAny(clicks, timer)
print("Thanks for using chatter!")
