--[[ CMTS (Cognitio Multi-Tenant SQLite3)

     This software made by Kuaralabs, assigned to 
     Yakup Cemil Kayabaş, published under MIT License.
                Copyright © Kuaralabs

     https://opensource.org/licenses/MIT

     This software covers all the titles needed for
     secure (Zero Trust) and multi-tenant database.
     
     Roadmap:
        - Delete comments and wrote these properly
        - Do not print, create table
        - Do not let search from table without 
          token id and user, after receiving, check 
          for harmoniousness of datas
        - Add delete 
        - Add search
]]

---@module LuaSQL-SQLite3
local db = require "luasql.sqlite3"
local env = db.sqlite3()
local maindDbFile = "maindb.sqlite"

local preDefinedUsers = {
    {id = 1, username = "kullanici1", token = "token1"},
    {id = 2, username = "kullanici2", token = "token2"},
    {id = 3, username = "kullanici3", token = "token3"}
}

local databaseCount = 0
local users = {}

function createTable(tableName, columns)

    local db = env:connect(dbFile)
    local request = string.format("CREATE TABLE IF NOT EXISTS %s (%s)", tableName, table.concat(columns, ", "))

    db:execute(request)
    db:close()
end

-- Kullanıcı ekleme fonksiyonu
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
    -- Yeni kullanıcıyı ekleyelim
    users[userId] = {username = username, token = token}

    databaseCount = databaseCount + 1
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