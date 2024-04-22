## Why SQLite3?

CMTS uses SQLite3 because it is unresponsive to calls from the outside of software you coded. Using SQLite3 can be an overexerting experience. CMTS aims use the Zero Trust concept and multi-tenancy abilities at isolated and unique databases.

## What CMTS Able To

CMTS is able to generate isolated databases for each user with irreplaceable identity tokens. Each user has own database at the end. Also, super-admin(s) has unique database that has all data about software and users init.

## Logging All Events with CognitioLogger

CMTS can log every event that happened at database handling process'. Logs with custom or presetted logging commands. 

### The presetted logging commands:
1. .succ("printed") -- prints -> "SUCCESS: printed"
1. .fail("abnormal") -- prints -> "FAILURE: abnormal"
1. .ok("all setted") -- prints -> "OK: all setted"