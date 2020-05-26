require "snippets"
local inspect = require "inspect"
local gr = love.graphics

function dist(x1, y1, x2, y2) 
    return ((x2 - x1) ^ 2 + (y2 - y1) ^ 2) ^ 0.5 
end

local Hex = {}
Hex.__index = Hex

function Hex:getVertices()
    local vertices = {}
    for i = 1, 6 do
        table.insert(vertices, self[i])
    end
    return vertices
end

function Hex:setMesh(mesh, endindex)
    self.mesh = mesh
    self.endindex = endindex
end

function Hex:setVertexColor(index, color)
    --local vertex = {self.mesh:getVertex(self.endindex - index + 1)}
    local vertex = {self.mesh:getVertex(self.endindex - index + 0)}

    self.mesh:setVertex(self.endindex - index + 0, vertex)
end

function Hex:setColor(color)
    for i = 1, 6 do
        self:setVertexColor(i, color)
    end
end

function newHexPolygon(cx, cy, rad)
    local hex = setmetatable({}, Hex)

    local d = math.pi * 2 / 6
    local c = 0
    for i = 1, 7 do
        local x, y = cx + math.sin(c) * rad, cy + math.cos(c) * rad
        table.insert(hex, x)
        table.insert(hex, y)
        c = c + d
    end

    hex.selected = false
    hex.cx, hex.cy = cx, cy

    return hex
end

function getHexPolygonWidth(hex)
    return dist(hex[3], hex[4], hex[11], hex[12])
end

function getHexPolygonHeight(hex)
    return dist(hex[1], hex[2], hex[7], hex[8])
end

function newHexField(startcx, startcy, xcount, ycount, rad, color)

    function addVertex(array, x, y)
        table.insert(array, {
            x, y,
            0, 0, -- u v
            color[1], color[2], color[3], color[4]
        })
        return #array
    end

    function addHex(data, hex)
        addVertex(data, hex.cx, hex.cy)
        addVertex(data, hex[1], hex[2])
        addVertex(data, hex[3], hex[4])

        addVertex(data, hex.cx, hex.cy)
        addVertex(data, hex[3], hex[4])
        addVertex(data, hex[5], hex[6])

        addVertex(data, hex.cx, hex.cy)
        addVertex(data, hex[5], hex[6])
        addVertex(data, hex[7], hex[8])

        addVertex(data, hex.cx, hex.cy)
        addVertex(data, hex[7], hex[8])
        addVertex(data, hex[9], hex[10])

        addVertex(data, hex.cx, hex.cy)
        addVertex(data, hex[9], hex[10])
        addVertex(data, hex[11], hex[12])

        addVertex(data, hex.cx, hex.cy)
        addVertex(data, hex[11], hex[12])
        return addVertex(data, hex[1], hex[2])
    end

    local result = {}
    local mesh = gr.newMesh(18 * xcount * ycount, "triangles", "dynamic")
    local meshData = {}

    local cx, cy = startcx, startcy
    local hasWH = false
    local w, h
    for j = 1, ycount do
        for i = 1, xcount do
            local last = newHexPolygon(cx, cy, rad)
            table.insert(result, last)
            if not hasWH then
                w, h = getHexPolygonWidth(result[#result]), 
                    getHexPolygonHeight(result[#result])
            end

            local lastIndex = addHex(meshData, last)
            last:setMesh(mesh, lastIndex)

            cx = cx + w
        end
        cy = cy + h * 3 / 4
        cx = j % 2 == 1 and startcx + w / 2 or startcx
    end

    mesh:setVertices(meshData)

    return result, mesh
end

local hexRad = 50
local hexColor = {0.5, 0.6, 1, 1}
local activeHexColor, passiveHexColor = {0.85, 0, 0, 1}, {0.5, 0.6, 0, 1}
local hexField, hexMesh = newHexField(80, 80, 200, 200, hexRad, passiveHexColor)

local hex = newHexPolygon(100, 100, 50)
local hexHeight = getHexPolygonHeight(hex)
local hexWidth = getHexPolygonWidth(hex)

function drawHexField(field)
    local prevColor = {gr.getColor()}
    local alpha = prevColor[4]
    local w, h = gr.getDimensions()
    for k, v in pairs(field) do
        if v.cx + hexRad < w or v.cy + hexRad < h then
            --if v.selected then
                --gr.setColor{1, 0, 0, alpha}
            --else
                --gr.setColor(prevColor)
            --end
            --gr.polygon("fill", v)
            --gr.setColor{0, 0, 0, alpha}
            gr.polygon("line", v)
        end
    end
end

function testHexDrawing()
    gr.setColor{0, 0.87, 0}
    gr.polygon("fill", hex)

    gr.setPointSize(10)
    gr.setColor{1, 0, 0}
    gr.points(hex[1], hex[2])
    gr.points(hex[3], hex[4])
    gr.setPointSize(1)

    gr.setColor{0, 0, 1}
    gr.line(hex[1], hex[2], hex[1], hex[2] - hexHeight)
    gr.line(hex[3], hex[4], hex[3] - hexWidth, hex[4])
end

love.draw = function()
    gr.setColor{1, 1, 1, 1}

    gr.push()
    gr.scale(0.05, 0.05)

    gr.draw(hexMesh)

    gr.setColor{0, 0.85, 0.1, 0.5}
    drawHexField(hexField)

    gr.pop()
    
    gr.setColor{1, 1, 1, 1}
    gr.print(string.format("FPS %d", love.timer.getFPS()))
end

function updateSelectedItem(x, y)
    for k, v in pairs(hexField) do
        if pointInPolygon(v, x, y) then
            --v:setColor(activeHexColor)
        else
            --v:setColor(passiveHexColor)
        end
    end
end

love.mousemoved = function(x, y, dx, dy)
    updateSelectedItem(x, y)
end

love.update = function(dt)
end

love.keypressed = function(_, k, isrepeat)
    if k == "escape" then
        love.event.quit()
    end
end
