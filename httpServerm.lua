function urlDecode(e)return e:gsub('%%(%x%x)',function(e)return string.char(tonumber(e,16))end)end
function guessType(n)local e={['.css']='text/css',['.js']='application/javascript',['.html']='text/html',['.png']='image/png',['.jpg']='image/jpeg'}for e,t in pairs(e)do
if string.sub(n,-string.len(e))==e
or string.sub(n,-string.len(e..'.gz'))==e..'.gz'then
return t
end
end
return'text/plain'end
Res={_skt=nil,_type=nil,_status=nil,_redirectUrl=nil,}function Res:new(n)local e={}setmetatable(e,self)self.__index=self
e._skt=n
return e
end
function Res:redirect(n,e)e=e or 302
self:status(e)self._redirectUrl=n
self:send(e)end
function Res:type(e)self._type=e
end
function Res:status(e)self._status=e
end
function Res:send(n)self._status=self._status or 200
self._type=self._type or'text/html'local e='HTTP/1.1 '..self._status..'\r\n'..'Content-Type: '..self._type..'\r\n'..'Content-Length:'..string.len(n)..'\r\n'if self._redirectUrl~=nil then
e=e..'Location: '..self._redirectUrl..'\r\n'end
e=e..'\r\n'..n
local function n()if e==''then
self:close()else
self._skt:send(string.sub(e,1,512))e=string.sub(e,513)end
end
self._skt:on('sent',n)n()end
function Res:sendFile(e)if file.exists(e..'.gz')then
e=e..'.gz'elseif not file.exists(e)then
self:status(404)if e=='404.html'then
self:send(404)else
self:sendFile('404.html')end
return
end
self._status=self._status or 200
local n='HTTP/1.1 '..self._status..'\r\n'self._type=self._type or guessType(e)n=n..'Content-Type: '..self._type..'\r\n'if string.sub(e,-3)=='.gz'then
n=n..'Content-Encoding: gzip\r\n'end
n=n..'\r\n'print('* Sending ',e)local t=0
local function s()file.open(e,'r')if file.seek('set',t)==nil then
self:close()print('* Finished ',e)else
local e=file.read(512)t=t+512
self._skt:send(e)end
file.close()end
self._skt:on('sent',s)self._skt:send(n)end
function Res:close()self._skt:on('sent',function()end)self._skt:on('receive',function()end)self._skt:close()self._skt=nil
end
function parseHeader(e,n)local r,i,t,s,n=string.find(e.source,'([A-Z]+) (.+)?(.+) HTTP')if t==nil then
i,i,t,s=string.find(e.source,'([A-Z]+) (.+) HTTP')end
local i={}if n~=nil then
n=urlDecode(n)for n,e in string.gmatch(n,'([^&]+)=([^&]*)&*')do
i[n]=e
end
end
e.method=t
e.query=i
e.path=s
return true
end
function staticFile(n,t)local e=''if n.path=='/'then
e='index.html'else
e=string.gsub(string.sub(n.path,2),'/','_')end
t:sendFile(e)end
httpServer={_srv=nil,_mids={{url='.*',cb=parseHeader},{url='.*',cb=staticFile}}}function httpServer:use(e,n)table.insert(self._mids,#self._mids,{url=e,cb=n})end
function httpServer:close()self._srv:close()self._srv=nil
end
function httpServer:listen(e)self._srv=net.createServer(net.TCP)self._srv:listen(e,function(e)e:on('receive',function(e,n)local n={source=n,path='',ip=e:getpeer()}local t=Res:new(e)for e=1,#self._mids do
if string.find(n.path,'^'..self._mids[e].url..'$')and not self._mids[e].cb(n,t)then
break
end
end
collectgarbage()end)end)end
