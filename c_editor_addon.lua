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

local function createEffect(element)
    element = element or source

    if (not isElement(element)) or (getElementType(element) ~= "addon_effect") then return end

    if (isElement(effectMatrix[element])) then
        destroyElement(effectMatrix[element])
    end

    effectMatrix[element] = _createEffect(
        exports.edf:edfGetElementProperty(element, "name"),
        Vector3(exports.edf:edfGetElementPosition(element)),
        Vector3(exports.edf:edfGetElementRotation(element)),
        exports.edf:edfGetElementProperty(element, "drawDistance") or 100,
        exports.edf:edfGetElementProperty(element, "soundEnable") == "true"
    )
    setEffectDensity(effectMatrix[element], math.max(0, math.min(2, exports.edf:edfGetElementProperty(element, "density") or 1.5)))
    setEffectSpeed(effectMatrix[element], math.max(0, exports.edf:edfGetElementProperty(element, "speed") or 1))
    setElementDimension(effectMatrix[element], exports.edf:edfGetElementDimension(element))
    setElementInterior(effectMatrix[element], exports.edf:edfGetElementInterior(element))
    setElementParent(effectMatrix[element], element)

    setElementAlpha(getRepresentation(element, "marker"), 0)
end
addEventHandler("onClientElementCreate", root, createEffect)

local function localCleanUp()
    if (not isElement(source)) or (getElementType(source) ~= "addon_effect") or (not effectMatrix[source]) then return end

    if (isElement(effectMatrix[source])) then
        destroyElement(effectMatrix[source])
    end

    effectMatrix[source] = nil
end
addEventHandler("onClientElementDestroyed", root, localCleanUp)
addEventHandler("onClientElementDestroy", root, localCleanUp)

addEventHandler("onClientElementPropertyChanged", root, function (propertyName)
    if (not isElement(source)) or (getElementType(source) ~= "addon_effect") then return end

    if (not isElement(effectMatrix[source])) then
        createEffect(source)
        return
    end

    if (propertyName == "density") then
        setEffectDensity(effectMatrix[source], math.max(0, math.min(2, exports.edf:edfGetElementProperty(source, "density") or 1.5)))
    elseif (propertyName == "speed") then
        setEffectSpeed(effectMatrix[source], math.max(0, exports.edf:edfGetElementProperty(source, "speed") or 1))
    else
        createEffect(source)
    end
end)

addEventHandler("onClientPreRender", root, function ()
    for element, effect in pairs(effectMatrix) do
        if (isElement(element)) then
            if (isElement(effect)) then
                setElementPosition(effect, exports.edf:edfGetElementPosition(element))
                setElementRotation(effect, exports.edf:edfGetElementRotation(element))
            elseif (exports.edf:edfGetElementProperty(element, "respawn") == "true") then
                createEffect(element)
            end
        end
    end
end)

function onStart()
    for _, element in pairs(getElementsByType("addon_effect")) do
        createEffect(element)
    end
end

function onStop()
    for element, effect in pairs(effectMatrix) do
        if (isElement(effect)) then
            destroyElement(effect)
        end

        effectMatrix[element] = nil
    end
end
addEventHandler("onClientResourceStop", resourceRoot, onStop)
