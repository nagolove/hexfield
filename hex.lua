﻿local inspect = require "inspect"
local gr = love.graphics
local vec = require "vector"
--local vec2 = require "vector-light"

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
    local vertex = {self.mesh:getVertex(self.endindex - index + 0)}
    --print("vertex", inspect(vertex))
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

function addVertex(array, x, y, color)
    table.insert(array, {
        x, y,
        0, 0, -- u v
        color[1], color[2], color[3], color[4]
    })
    return #array
end

function addHex(data, hex, color)
    addVertex(data, hex.cx, hex.cy, color)
    addVertex(data, hex[1], hex[2], color)
    addVertex(data, hex[3], hex[4], color)

    addVertex(data, hex.cx, hex.cy, color)
    addVertex(data, hex[3], hex[4], color)
    addVertex(data, hex[5], hex[6], color)

    addVertex(data, hex.cx, hex.cy, color)
    addVertex(data, hex[5], hex[6], color)
    addVertex(data, hex[7], hex[8], color)

    addVertex(data, hex.cx, hex.cy, color)
    addVertex(data, hex[7], hex[8], color)
    addVertex(data, hex[9], hex[10], color)

    addVertex(data, hex.cx, hex.cy, color)
    addVertex(data, hex[9], hex[10], color)
    addVertex(data, hex[11], hex[12], color)

    addVertex(data, hex.cx, hex.cy, color)
    addVertex(data, hex[11], hex[12], color)
    return addVertex(data, hex[1], hex[2], color)
end

function addVertex2(array, x, y)
    table.insert(array, {
        x, y,
        --math.floor(x), math.floor(y),
        0, 0, -- u v
        1, 1, 1, 1,
    })
end

-- добавляет линию из пары треугольников и шести вершин
function addLine(array, x1, y1, x2, y2)
    --TODO Оптимизировать вектора
    local len = dist(x1, y1, x2, y2)
    local dirx, diry = vec(x2 - x1) / len, vec(y2 - y1) / len
    local dir1, dir2 = vec(x2 - x1, y2 - y1) / len, vec(x1 - x2, y1 - y2) / len

    local width = 3
    local p1 = vec(x1, y1) + dir1:perpendicular() * width
    local p2 = vec(x1, y1) + dir2:perpendicular() * width
    local p3 = vec(x2, y2) + dir1:perpendicular() * width
    local p4 = vec(x2, y2) + dir2:perpendicular() * width

    addVertex2(array, p1.x, p1.y)
    addVertex2(array, p2.x, p2.y)
    addVertex2(array, p3.x, p3.y)

    addVertex2(array, p4.x, p4.y)
    addVertex2(array, p3.x, p3.y)
    addVertex2(array, p2.x, p2.y)
end

function addBorder(data, hex)
    addLine(data, hex[1], hex[2], hex[3], hex[4])
    addLine(data, hex[3], hex[4], hex[5], hex[6])
    addLine(data, hex[5], hex[6], hex[7], hex[8])
    addLine(data, hex[7], hex[8], hex[9], hex[10])
    addLine(data, hex[9], hex[10], hex[11], hex[12])
    addLine(data, hex[11], hex[12], hex[1], hex[2])
end

function newHexField(startcx, startcy, xcount, ycount, rad, color)

    local result = {}
    local mesh = gr.newMesh((6 * 3 + 6 * 6) * xcount * ycount, "triangles", "dynamic")
    local meshData = {}

    local cx, cy = startcx, startcy
    local hasWH = false
    local w, h

    local prevHorizon = nil
    local horizon = {}

    for j = 1, ycount do
        for i = 1, xcount do
            local last = newHexPolygon(cx, cy, rad)
            last.j = j
            last.i = i
            --table.insert(result, last)
            table.insert(horizon, last)

            --[[ 
            [1] left 
            [2] lt
            [3] rt 
            [4] right 
            [5] rb 
            [6] lb ]]
            last.refs = {} 

            for i = 1, 6 do
                last.refs[#last.refs + 1] = false
            end

            if prevHorizon then
                last.refs[2] = prevHorizon[i]
                if i + 1 <= #prevHorizon then
                    last.refs[2] = prevHorizon[i + 1]
                end
            end
            if i > 1 then
                last.refs[1] = horizon[i - 1]

                horizon[i - 1].refs[4] = last
            end

            if not hasWH then
                w, h = getHexPolygonWidth(last), getHexPolygonHeight(last)
            end

            local lastIndex = addHex(meshData, last, color)
            addBorder(meshData, last)
            last:setMesh(mesh, lastIndex)

            cx = cx + w
        end

        for k, v in pairs(horizon) do
            table.insert(result, v)
        end
        prevHorizon = horizon
        horizon = {}

        cy = cy + h * 3 / 4
        cx = j % 2 == 1 and startcx + w / 2 or startcx
    end
    
    --updateNeighbors(result, xcount, ycount)
    mesh:setVertices(meshData)

    return result, mesh
end

function updateNeighbors(tbl, xcount, ycount)
    for k, v in pairs(tbl) do
        v.refs = {
            --[[
            left lt top rt right rb bottom lb
            --]]
        }
        if v.j > 1 then

        end
    end
end

