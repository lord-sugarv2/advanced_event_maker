local MODULE = table.Copy(AEvent.BaseModule)
MODULE.CategoryID = "Command:Other"
MODULE.Name = "Other"

MODULE:AddCommand({
    ID = "Command:Other:Print",
    Name = "print in console",
    ExtraSelection = function()
        return {"String Input", "input a phrase"}
    end,
    RunCommand = function(data)
        print("[ AEvent ] "..data.Selection)
    end,
})