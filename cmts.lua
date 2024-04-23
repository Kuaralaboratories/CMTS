--[[ CMTS (Cognitios Multi-Tenant SQLite3)

     This software made by Kuaralabs, assigned to 
     Yakup Cemil Kayabaş, published under GPL License.
                Copyright © Kuaralabs

     https://www.gnu.org/licenses/gpl-3.0.html

     This software covers all the titles needed for
     secure (Zero Trust) and multi-tenant database.
     
     Roadmap:
        - Delete comments and wrote these properly ()
        - Do not print, create table (ok)
        - Do not let search from table without 
          token id and user, after receiving, check 
          for harmoniousness of datas (ok)
        - Add all commands for SQL (ok)
        - Create basic tables for event-logs, users, user-logs ()
        - Create super-admin and give to developer, thus, add to main database ()
        - Make the auth for main database, only super-admin can access () 
]]

---@module LuaSQL-SQLite3
local db = require "luasql.sqlite3"

local env = db.sqlite3()
local maindDbFile = "maindb.sqlite"

local function generateSuperAdminTokenAndId()
    local charset = "abcdl345@JKLMNO$#,TUVstuvwXYxyzABWZ0.!efghijk*?/6789{(GHIPS1}opqr])QR[mnCDEF2~"
    local token = ""
    local id = ""

    -- 256 char length token
    for i = 1, 256 do
        local char = charset:sub(math.random(1, #charset), math.random(1, #charset))
        token = token .. char
    end

    -- 16 digit length id
    for i = 1, 16 do
        local digit = tostring(math.random(0, 9))
        id = id .. digit
    end

    return token, id
end

-- Create the super-admin
local superAdminToken, superAdminId = generateSuperAdminTokenAndId()

local preDefinedUsers = {
    {id = 1, username = "kullanici1", token = "token1"},
    {id = 2, username = "kullanici2", token = "token2"},
    {id = 3, username = "kullanici3", token = "token3"}
}

local databaseCount = 0
local users = {}

---@param tableName string
---@param columns string
function createTable(userId, token, tableName, columns)

    if not authenticateUser(userId, token) then
        error("Kullanıcı doğrulaması başarısız. İşlem yapılamadı.", 2)
    end

    local database = env:connect(dbFile)
    local request = string.format("CREATE TABLE IF NOT EXISTS %s (%s)", tableName, table.concat(columns, ", "))

    db:execute(request)
    db:close()
end

---@param tableName string
function deleteTable(userId, token, tableName)

    if not authenticateUser(userId, token) then
        error("Kullanıcı doğrulaması başarısız. İşlem yapılamadı.", 2)
    end

    local db = env:connect(dbFile)
    local request = string.format("DROP TABLE %s", tableName)

    db:execute(request)
    db:close()
end

---@param tableName string
---@param columns string
function updateTable(userId, token, tableName, columns)

    if not authenticateUser(userId, token) then
        error("Kullanıcı doğrulaması başarısız. İşlem yapılamadı.", 2)
    end

    local db = env:connect(dbFile)
    local exists_query = string.format("SELECT count(*) FROM sqlite_master WHERE type='table' AND name='%s'", tableName)
    local exists_result = db:execute(exists_query):fetch()
    local table_exists = exists_result[1] > 0
    
    if table_exists then
        -- Tablo varsa, tabloyu yeniden oluştur
        local drop_query = string.format("DROP TABLE %s", tableName)
        db:execute(drop_query)
    end

    -- Yeni tabloyu oluştur
    local create_query = string.format("CREATE TABLE %s (%s)", tableName, table.concat(columns, ", "))
    db:execute(create_query)
    
    db:close()
end

---@param tableName string
---@param columns string
---@param condition string
function searchFromTable(uerId, token, tableName, columns, condition)

    if not authenticateUser(userId, token) then
        error("Kullanıcı doğrulaması başarısız. İşlem yapılamadı.", 2)
    end

    local db = env:connect(dbFile)
    local columnStr = "*"
    if type(columns) == "table" then
        if columns[1] == "all" or columns[1] == "*" then
            columnStr = "*"
        else
            columnStr = table.concat(columns, ", ")
        end
    end

    local query = string.format("SELECT %s FROM %s", columnStr, tableName)
    if condition then
        query = query .. " WHERE " .. condition
    end

    local results = {}
    for row in db:nrows(query) do
        table.insert(results, row)
    end
    
    db:close()
    return results
end

---@param tableName string
---@param indexName string
---@param columnName string
function createIndex(userId, token, indexName, tableName, columnName)

    if not authenticateUser(userId, token) then
        error("Kullanıcı doğrulaması başarısız. İşlem yapılamadı.", 2)
    end

    local db = env:connect(dbFile)

    local query = string.format("CREATE INDEX %s ON %s (%s)", indexName, tableName, columnName)
    db:execute(query)
    db:close()
end

---@param tableName string
---@param setValues string
---@param condition string
function updateData(userId, token, tableName, setValues, condition)

    if not authenticateUser(userId, token) then
        error("Kullanıcı doğrulaması başarısız. İşlem yapılamadı.", 2)
    end

    local db = env:connect(dbFile)

    local setStr = ""
    for column, value in pairs(setValues) do
        setStr = setStr .. column .. " = '" .. value .. "', "
    end
    setStr = setStr:sub(1, -3) -- delete the last comma

    local query = string.format("UPDATE %s SET %s", tableName, setStr)
    if condition then
        query = query .. " WHERE " .. condition
    end

    db:execute(query)
    db:close()
end

---@param tableName string
---@param condition string
function deleteData(userId, token, tableName, condition)

    if not authenticateUser(userId, token) then
        error("Kullanıcı doğrulaması başarısız. İşlem yapılamadı.", 2)
    end

    local db = env:connect(dbFile)

    local query = string.format("DELETE FROM %s", tableName)
    if condition then
        query = query .. " WHERE " .. condition
    end

    db:execute(query)
    db:close()
end

---@param tableName string
---@param values string
function insertData(userId, token, tableName, values)

    if not authenticateUser(userId, token) then
        error("Kullanıcı doğrulaması başarısız. İşlem yapılamadı.", 2)
    end

    local db = env:connect(dbFile)

    local columns = {}
    local valuePlaceholders = {}
    for column, value in pairs(values) do
        table.insert(columns, column)
        if type(value) == "string" then
            value = "'" .. value .. "'"
        end
        table.insert(valuePlaceholders, value)
    end

    local query = string.format("INSERT INTO %s (%s) VALUES (%s)", tableName, table.concat(columns, ", "), table.concat(valuePlaceholders, ", "))
    db:execute(query)
    db:close()
end

---@param userId number
---@param username string
---@param token string
local function addUser(userId, username, token)
    -- Eğer ID, kullanıcı adı veya token girişi yoksa, kullanıcı eklenmez
    if not userId or not username or not token or userId == "" or username == "" or token == "" then
        print("Eksik bilgi. Kullanıcı oluşturulmadı.")
        return
    end
    -- Kullanıcı tablosunda zaten bu ID ile bir kullanıcı varsa, işlem yapma
    for existingUserId, userData in pairs(users) do
        if existingUserId == userId or userData.username == username or userData.token == token then
            print("Hata: Aynı ID, kullanıcı adı veya token zaten mevcut. Kullanıcı eklenmedi.")
            return
        end
    end

    if not authenticateUser(userId, token) then
        error("Kullanıcı doğrulaması başarısız. İşlem yapılamadı.", 2)
    end

    -- Yeni kullanıcıyı ekleyelim
    users[userId] = {username = username, token = token}

    databaseCount = databaseCount + 1
end

authenticateUser = function(userId, token)
    for _, userData in pairs(preDefinedUsers) do
        if userData.id == userId and userData.token == token then
            return true
        end
    end
    return false
end

local dbFiles = {}
for _, userData in ipairs(preDefinedUsers) do
    local username = userData.username
    local dbFile = username .. ".sqlite"
    table.insert(dbFiles, dbFile)
end

-- Hazır verileri kullanarak kullanıcıları ekleyelim
for _, userData in ipairs(preDefinedUsers) do
    addUser(userData.id, userData.username, userData.token)
end

-- Kullanıcıları ekrana yazdıran fonksiyon
local function printUsers()
    print("Kullanıcılar:")
    for userId, userData in pairs(users) do
        print("ID:", userId, "Kullanıcı Adı:", userData.username, "Token:", userData.token)
        print("\nDatabases:", dbFiles)
    end
end

-- Kullanıcıları ekrana yazdıralım
printUsers()

print("\nOluşturulan veritabanı sayısı:", databaseCount)

print("\nVeritabanı dosya adları:")
for _, dbFile in ipairs(dbFiles) do
    print(dbFile)
end