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
local effectMatrix = {}
local _createEffect = createEffect
local rendering

local function createEffect(element)
    if (not isElement(element)) or (getElementType(element) ~= "addon_effect") then return end

    if (isElement(effectMatrix[element])) then
        destroyElement(effectMatrix[element])
    end

    local existed = effectMatrix[element] ~= nil

    effectMatrix[element] = true

    if (not existed) then
        setElementDimension(element, getElementData(element, "dimension"))
        setElementInterior(element, getElementData(element, "interior"))

        addEventHandler("onClientElementDimensionChange", element, function (_, newDimension)
            if (newDimension == getElementDimension(localPlayer)) then
                createEffect(source)
            elseif (isElement(effectMatrix[source])) then
                destroyElement(effectMatrix[source])
            end
        end)

        addEventHandler("onClientElementInteriorChange", element, function (_, newInterior)
            if (newInterior == getElementInterior(localPlayer)) then
                createEffect(source)
            elseif (isElement(effectMatrix[source])) then
                destroyElement(effectMatrix[source])
            end
        end)
    end

    if (getElementDimension(element) == getElementDimension(localPlayer)) and (getElementInterior(element) == getElementInterior(localPlayer)) then
        effectMatrix[element] = _createEffect(
            getElementData(element, "name"),
            Vector3(getElementPosition(element)),
            Vector3(getElementRotation(element)),
            getElementData(element, "drawDistance") or 100,
            getElementData(element, "soundEnable") == "true"
        )
        setElementDimension(effectMatrix[element], getElementDimension(element))
        setElementInterior(effectMatrix[element], getElementInterior(element))
        setEffectDensity(effectMatrix[element], math.max(0, math.min(2, getElementData(element, "density") or 1.5)))
        setEffectSpeed(effectMatrix[element], math.max(0, getElementData(element, "speed") or 1))
        setElementParent(effectMatrix[element], element)

        addEventHandler("onClientElementDimensionChange", effectMatrix[element], function (_, newDimension)
            if (newDimension == getElementDimension(localPlayer)) then
                createEffect(getElementParent(source))
            else
                destroyElement(source)
            end
        end)

        addEventHandler("onClientElementInteriorChange", effectMatrix[element], function (_, newInterior)
            if (newInterior == getElementInterior(localPlayer)) then
                createEffect(getElementParent(source))
            else
                destroyElement(source)
            end
        end)
    end
end

local function renderEffectRespawn()
    for element, effect in pairs(effectMatrix) do
        if (isElement(element))
            and (not isElement(effect))
            and (getElementData(element, "respawn") == "true")
            and (getElementDimension(element) == getElementDimension(localPlayer))
            and (getElementInterior(element) == getElementInterior(localPlayer))
        then
            createEffect(element)
        end
    end
end

local function toggleRendering(foundEffect)
    if (foundEffect) and (not rendering) then
        addEventHandler("onClientPreRender", root, renderEffectRespawn)
        rendering = true
    elseif (not foundEffect) and (rendering) then
        removeEventHandler("onClientPreRender", root, renderEffectRespawn)
        rendering = false
    end
end

addEventHandler("onClientResourceStart", root, function ()
    local foundEffect = false

    for _, element in pairs(getElementsByType("addon_effect", source == resourceRoot and root or source)) do
        local effect = getElementChildren(element, "addon_effect")[1]

        if (isElement(effect)) then
            effectMatrix[element] = effect
        end

        createEffect(element)
        foundEffect = true
    end

    toggleRendering(foundEffect)
end)

addEventHandler("onClientElementDimensionChange", localPlayer, function (_, newDimension)
    for element, effect in pairs(effectMatrix) do
        if (isElement(element)) and (getElementDimension(element) == newDimension) then
            createEffect(element)
        elseif (isElement(effect)) then
            destroyElement(effect)
        end
    end
end)

addEventHandler("onClientElementInteriorChange", localPlayer, function (_, newInterior)
    for element, effect in pairs(effectMatrix) do
        if (isElement(element)) and (getElementInterior(element) == newInterior) then
            createEffect(element)
        elseif (isElement(effect)) then
            destroyElement(effect)
        end
    end
end)

addEventHandler("onClientElementDestroy", root, function ()
    toggleRendering(#getElementsByType("addon_effect") > 0)
end)
