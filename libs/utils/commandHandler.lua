local stringx = require('utils/stringx')

--- Default command handler
---@param client SuperToastClient
---@param msg Message
return function(client, msg)
   local pre = client.config.prefix

   if not stringx.startswith(msg.content, pre) then
      return
   end

   if msg.author.bot then
      return
   end

   local command = string.match(msg.content, pre .. '(%S+)'):lower()

   if not command then
      return
   end

   local args = {}

   for arg in string.gmatch(string.match(msg.content, pre .. '%S+%s*(.*)'), '%S+') do
      table.insert(args, arg)
   end

   local found = client.commands:find(function(cmd)
      return cmd.name == command or cmd.aliases:find(function(alias)
         return alias == command
      end)
   end)

   if found then
      local toRun = found:toRun(msg, args)

      if type(toRun) == 'string' then
         msg:reply(client.config.errorResolver(found, toRun))
      else
         local succ, err = pcall(toRun, msg, args, client)

         if not succ then
            msg:reply('Something went wrong, try again later')

            client:error(err)
         end
      end
   end
end
