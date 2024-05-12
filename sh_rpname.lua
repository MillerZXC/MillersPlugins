PLUGIN.name = "RPname command"
PLUGIN.desc = "Just a simple RPname command, that changes YOUR nickname"

ix.command.Add("RPname", {
	description = "Меняет ваше имя",
	adminOnly = false,
	arguments = {
		bit.bor(ix.type.text, ix.type.optional)
	},

	OnRun = function(self, client, newName)
		if (newName:len() == 0) then
			return client:RequestString("@chgName", "@chgNameDesc", function(text)
				ix.command.Run(client, "CharSetName", {target:client(), text})
			end, client:GetName())
		end

		for _, v in ipairs(player.GetAll()) do
			if (self:OnCheckAccess(v) or v == client:GetPlayer()) then
				v:NotifyLocalized("cChangeName", client:GetName(), client:GetName(), newName)
			end
		end

		client:GetCharacter():SetName(newName)
	end
})
