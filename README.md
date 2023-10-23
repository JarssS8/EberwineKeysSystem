# EberwineKeysSystem
## Staff Permissions
We are using IsStaff() function for most of the functionalities, if you don't have this function replace it for other one for example IsAdmin()

## Plugin language
The plugin for the moment is on spanish and don't have translations system.

## Commands
Temp tables are tables saved ONLY on cache, if the sever restart this will not be the same. Be consecuent with that.
/AddDoorToTempTable "uniqueKey" -> Add the door you are looking for to a temp table
/CopyDoorTempTable "uniqueKey" -> Copy the whole table with all the doors that it contains to your clipboard
/GetPreloadedKeys -> Get the name of all your preloaded keys, setted up on sh_plugin.lua
/CreateCustomKey "preloaded_name" -> Create a key in your inv with the preloaded values assigned.