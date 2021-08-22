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
local rendering

local function hex2rgba(hex)
    local hex = hex:gsub("#", "")
    return tonumber("0x" .. hex:sub(1, 2)), tonumber("0x" .. hex:sub(3, 4)), tonumber("0x" .. hex:sub(5, 6)), tonumber("0x" .. hex:sub(7, 8))
end

local function createParticle(element)
    local particleType = getElementType(element)

    if (not isElement(element)) or (not particleTypes[particleType]) then return end

    local existed = particleMatrix[element] ~= nil

    particleMatrix[element] = getElementData(element, "respawn") == "true" and {
        lastTick = getTickCount(),
        respawnTime = getElementData(element, "respawnTime") or 0,
    } or true

    if (not existed) then
        setElementDimension(element, getElementData(element, "dimension"))
        setElementInterior(element, getElementData(element, "interior"))

        addEventHandler("onClientElementDimensionChange", element, function (oldDimension, newDimension)
            if (newDimension == getElementDimension(localPlayer)) then
                createParticle(source)
            end
        end)
    
        addEventHandler("onClientElementInteriorChange", element, function (oldInterior, newInterior)
            if (newInterior == getElementInterior(localPlayer)) then
                createParticle(source)
            end
        end)
    end

    if (getElementDimension(element) == getElementDimension(localPlayer)) and (getElementInterior(element) == getElementInterior(localPlayer)) then
        local x, y, z = getElementPosition(element)
        local _, _, rz = tonumber(getElementData(element, "rotX")), tonumber(getElementData(element, "rotY")), tonumber(getElementData(element, "rotZ"))
        local r, g, b, a = hex2rgba(getElementData(element, "color") or "#ff0000")
        local _tx, _ty, tz
        local tx, ty
        local direction = getElementData(element, "direction")
    
        if (direction) then
            _tx, _ty, tz = unpack(split(direction, ","))
            _tx, _ty, tz = tonumber(_tx), tonumber(_ty), tonumber(tz)
            tx, ty = x + (_tx - x) * math.cos(math.rad(rz)) - (_ty - y) * math.sin(math.rad(rz)), y + (_tx - x) * math.sin(math.rad(rz)) + (_ty - y) * math.cos(math.rad(rz))
        end
    
        if (particleType == "addon_particle_blood") then
            fxAddBlood(
                x, y, z,
                tx, ty, tz,
                getElementData(element, "count") or 1,
                getElementData(element, "brightness") or 1
            )
        elseif (particleType == "addon_particle_bullet_impact") then
            fxAddBulletImpact(
                x, y, z,
                tx, ty, tz,
                getElementData(element, "smokeSize") or 1,
                getElementData(element, "sparkCount") or 1,
                getElementData(element, "smokeIntensity") or 1
            )
        elseif (particleType == "addon_particle_bullet_splash") then
            fxAddBulletSplash(x, y, z)
        elseif (particleType == "addon_particle_debris") then
            fxAddDebris(
                x, y, z,
                r, g, b, a,
                getElementData(element, "scale") or 1,
                getElementData(element, "count") or 1
            )
        elseif (particleType == "addon_particle_foot_splash") then
            fxAddFootSplash(x, y, z)
        elseif (particleType == "addon_particle_glass") then
            fxAddGlass(
                x, y, z,
                r, g, b, a,
                getElementData(element, "scale") or 1,
                getElementData(element, "count") or 1
            )
        elseif (particleType == "addon_particle_gunshot") then
            fxAddGunshot(
                x, y, z,
                tx, ty, tz,
                getElementData(element, "includeSparks") == "true"
            )
        elseif (particleType == "addon_particle_punch_impact") then
            fxAddPunchImpact(x, y, z, tx, ty, tz)
        elseif (particleType == "addon_particle_sparks") then
            fxAddSparks(
                x, y, z,
                Vector3(getElementData(element, "rDirection")),
                getElementData(element, "force") or 1,
                getElementData(element, "count") or 1,
                Vector3(getElementData(element, "acrossLine")),
                getElementData(element, "blur") == "true",
                getElementData(element, "spread") or 1,
                getElementData(element, "life") or 1
            )
        elseif (particleType == "addon_particle_tank_fire") then
            fxAddTankFire(x, y, z, tx, ty, tz)
        elseif (particleType == "addon_particle_tyre_burst") then
            fxAddTyreBurst(x, y, z, tx, ty, tz)
        elseif (particleType == "addon_particle_water_hydrant") then
            fxAddWaterHydrant(x, y, z)
        elseif (particleType == "addon_particle_water_splash") then
            fxAddWaterSplash(x, y, z)
        elseif (particleType == "addon_particle_wood") then
            fxAddWood(
                x, y, z,
                tx, ty, tz,
                getElementData(element, "count") or 1,
                getElementData(element, "brightness") or 1
            )
        end

        particleMatrix[element].ran = true
    end
end

local function renderParticleRespawn()
    local tick = getTickCount()

    for element, settings in pairs(particleMatrix) do
        if (isElement(element))
            and (settings ~= true)
            and ((tick >= settings.lastTick + settings.respawnTime) or (not settings.ran))
            and (getElementDimension(element) == getElementDimension(localPlayer))
            and (getElementInterior(element) == getElementInterior(localPlayer))
        then
            createParticle(element)
        end
    end
end

local function toggleRendering(foundParticle)
    if (foundParticle) and (not rendering) then
        addEventHandler("onClientPreRender", root, renderParticleRespawn)
        rendering = true
    elseif (not foundParticle) and (rendering) then
        removeEventHandler("onClientPreRender", root, renderParticleRespawn)
        rendering = false
    end
end

addEventHandler("onClientResourceStart", root, function ()
    local foundParticle = false

    for particleType in pairs(particleTypes) do
        for _, element in pairs(getElementsByType(particleType, source == resourceRoot and root or source)) do
            createParticle(element)
            foundParticle = true
        end
    end

    toggleRendering(foundParticle)
end)

addEventHandler("onClientElementDimensionChange", localPlayer, function (_, newDimension)
    for element, settings in pairs(particleMatrix) do
        particleMatrix[element].ran = false

        if (isElement(element)) and (getElementDimension(element) == newDimension) then
            createParticle(element)
        end
    end
end)

addEventHandler("onClientElementInteriorChange", localPlayer, function (_, newInterior)
    for element, settings in pairs(particleMatrix) do
        particleMatrix[element].ran = false

        if (isElement(element)) and (getElementInterior(element) == newInterior) then
            createParticle(element)
        end
    end
end)

addEventHandler("onClientElementDestroy", root, function ()
    local count = 0

    for particleType in pairs(particleTypes) do
        count = count + #getElementsByType(particleType)
    end

    toggleRendering(count > 0)
end)
