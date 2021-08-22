--[[
    This resource is officially available on GitHub at
    https://github.com/patrikjuvonen/editor_addon_effects

    MIT License

    Copyright (c) 2021 patrikjuvonen

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
]]
local particleMatrix = {}
local particleTypes = {
    ["addon_particle_blood"] = true, ["addon_particle_bullet_impact"] = true, ["addon_particle_bullet_splash"] = true, ["addon_particle_debris"] = true,
    ["addon_particle_foot_splash"] = true, ["addon_particle_glass"] = true, ["addon_particle_gunshot"] = true, ["addon_particle_punch_impact"] = true,
    ["addon_particle_sparks"] = true, ["addon_particle_tank_fire"] = true, ["addon_particle_tyre_burst"] = true, ["addon_particle_water_hydrant"] = true,
    ["addon_particle_water_splash"] = true, ["addon_particle_wood"] = true
}

local function getRepresentation(element, type)
    local elemTable = {}

    for _, elem in pairs(getElementsByType(type, element)) do
        if (elem ~= exports.edf:edfGetHandle(elem)) then
            table.insert(elemTable, elem)
        end
    end

    if (#elemTable == 0) then
        return false
    elseif (#elemTable == 1) then
        return elemTable[1]
    end

    return elemTable
end

local function hex2rgba(hex)
    local hex = hex:gsub("#", "")
    return tonumber("0x" .. hex:sub(1, 2)), tonumber("0x" .. hex:sub(3, 4)), tonumber("0x" .. hex:sub(5, 6)), tonumber("0x" .. hex:sub(7, 8))
end

local function createParticle(element)
    element = element or source

    local particleType = getElementType(element)

    if (not isElement(element)) or (not particleTypes[particleType]) then return end

    particleMatrix[element] = exports.edf:edfGetElementProperty(element, "respawn") == "true" and {
        lastTick = getTickCount(),
        respawnTime = exports.edf:edfGetElementProperty(element, "respawnTime") or 0,
    } or true

    local position = Vector3(exports.edf:edfGetElementPosition(element))
    local rotation = Vector3(exports.edf:edfGetElementRotation(element))
    local matrix = Matrix(position, rotation)
    local direction = Vector3(matrix:getForward() * (exports.edf:edfGetElementProperty(element, "distance") or 1))
    local r, g, b, a = hex2rgba(exports.edf:edfGetElementProperty(element, "color") or "#ff0000")

    if (particleType == "addon_particle_blood") then
        fxAddBlood(
            position,
            direction,
            exports.edf:edfGetElementProperty(element, "count") or 1,
            exports.edf:edfGetElementProperty(element, "brightness") or 1
        )
    elseif (particleType == "addon_particle_bullet_impact") then
        fxAddBulletImpact(
            position,
            direction,
            exports.edf:edfGetElementProperty(element, "smokeSize") or 1,
            exports.edf:edfGetElementProperty(element, "sparkCount") or 1,
            exports.edf:edfGetElementProperty(element, "smokeIntensity") or 1
        )
    elseif (particleType == "addon_particle_bullet_splash") then
        fxAddBulletSplash(position)
    elseif (particleType == "addon_particle_debris") then
        fxAddDebris(
            position,
            r, g, b, a,
            exports.edf:edfGetElementProperty(element, "scale") or 1,
            exports.edf:edfGetElementProperty(element, "count") or 1
        )
    elseif (particleType == "addon_particle_foot_splash") then
        fxAddFootSplash(position)
    elseif (particleType == "addon_particle_glass") then
        fxAddGlass(
            position,
            r, g, b, a,
            exports.edf:edfGetElementProperty(element, "scale") or 1,
            exports.edf:edfGetElementProperty(element, "count") or 1
        )
    elseif (particleType == "addon_particle_gunshot") then
        fxAddGunshot(
            position,
            direction,
            exports.edf:edfGetElementProperty(element, "includeSparks") == "true"
        )
    elseif (particleType == "addon_particle_punch_impact") then
        fxAddPunchImpact(position, direction)
    elseif (particleType == "addon_particle_sparks") then
        fxAddSparks(
            position,
            Vector3(exports.edf:edfGetElementProperty(element, "rDirection")),
            exports.edf:edfGetElementProperty(element, "force") or 1,
            exports.edf:edfGetElementProperty(element, "count") or 1,
            Vector3(exports.edf:edfGetElementProperty(element, "acrossLine")),
            exports.edf:edfGetElementProperty(element, "blur") == "true",
            exports.edf:edfGetElementProperty(element, "spread") or 1,
            exports.edf:edfGetElementProperty(element, "life") or 1
        )
    elseif (particleType == "addon_particle_tank_fire") then
        fxAddTankFire(position, direction)
    elseif (particleType == "addon_particle_tyre_burst") then
        fxAddTyreBurst(position, direction)
    elseif (particleType == "addon_particle_water_hydrant") then
        fxAddWaterHydrant(position)
    elseif (particleType == "addon_particle_water_splash") then
        fxAddWaterSplash(position)
    elseif (particleType == "addon_particle_wood") then
        fxAddWood(
            position,
            direction,
            exports.edf:edfGetElementProperty(element, "count") or 1,
            exports.edf:edfGetElementProperty(element, "brightness") or 1
        )
    end

    setElementAlpha(getRepresentation(element, "marker"), 50)
end
addEventHandler("onClientElementCreate", root, createParticle)

local function localCleanUp()
    if (not isElement(source)) or (not particleTypes[getElementType(source)]) or (not particleMatrix[source]) then return end

    particleMatrix[source] = nil
end
addEventHandler("onClientElementDestroyed", root, localCleanUp)
addEventHandler("onClientElementDestroy", root, localCleanUp)

addEventHandler("onClientElementPropertyChanged", root, function (propertyName)
    if (not isElement(source)) or (not particleTypes[getElementType(source)]) then return end

    createParticle(source)
end)

addEventHandler("onClientPreRender", root, function ()
    local tick = getTickCount()

    for element, settings in pairs(particleMatrix) do
        if (isElement(element)) and (settings ~= true) and (tick >= settings.lastTick + settings.respawnTime) then
            createParticle(element)
        end
    end
end)

function onStart()
    for particleType in pairs(particleTypes) do
        for _, element in pairs(getElementsByType(particleType)) do
            createParticle(element)
        end
    end
end
