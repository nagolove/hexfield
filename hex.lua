local gr = love.graphics

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

    function addVertex2(array, x, y)
        table.insert(array, {
            --x + 500, y + 500,
            x, y,
            0, 0, -- u v
            1, 1, 1, 1,
        })
    end

    -- добавляет линию из пары треугольников и шести вершин
    function addLine(array, x1, y1, x2, y2)
        local len = dist(x1, y1, x2, y2)
        local dirx, diry = (x2 - x1) / len, (y2 - y1) / len
        local width = 10
        local p1x, p1y = x1 + dirx * width, y1 + -diry * width
        local p2x, p2y = x1 + dirx * width, y1 + -diry * width
        local p3x, p3y = x2 + -dirx * width, y2 + diry * width
        local p4x, p4y = x2 + -dirx * width, y2 + diry * width
        --local p1x, p1y = x1 + -dirx * width, y1 + diry * width
        --local p2x, p2y = x1 + dirx * width, y1 + -diry * width
        --local p3x, p3y = x2 + -dirx * width, y2 + diry * width
        --local p4x, p4y = x2 + dirx * width, y2 + -diry * width

        --print(p1x, p1x)
        --print(p2x, p2y)
        
        write2Canvas(function()
            gr.setColor{1, 0, 1}
            gr.line(x1, y1, x2, y2)
            local y = 0
            gr.print(string.format("len %f", len), 0, y)
            y = y + gr.getFont():getHeight()
            gr.print(string.format("dirx %f, diry %f", dirx, diry), 0, y)
            y = y + gr.getFont():getHeight()

            gr.setColor{0, 0, 0}
            gr.points(100, 100)

            gr.setPointSize(3)

            gr.points(p1x, p1y, p2x, p2y)
            gr.points(p3x, p3y, p4x, p4y)

            gr.setColor{0.1, 0.7, 0.2, 0.4}
            gr.print("p1", p1x, p1y)
            gr.print("p2", p2x, p2y)
            gr.print("p3", p3x, p3y)
            gr.print("p4", p4x, p4y)
        end)

        addVertex2(array, p1x, p1y)
        addVertex2(array, p4x, p4y)
        addVertex2(array, p3x, p3y)

        addVertex2(array, p4x, p4y)
        addVertex2(array, p2x, p2y)
        addVertex2(array, p1x, p1y)
    end

    function addBorder(data, hex)
--[[
   [        addLine(data, hex[1], hex[2], hex[3], hex[4])
   [        addLine(data, hex[3], hex[4], hex[5], hex[6])
   [        addLine(data, hex[5], hex[6], hex[7], hex[8])
   [        addLine(data, hex[7], hex[8], hex[9], hex[10])
   [
   [        addLine(data, hex[9], hex[10], hex[11], hex[12])
   [        --addLine(data, hex[9] + 100, hex[10], hex[11] + 107, hex[12])
   [
   [        addLine(data, hex[11], hex[12], hex[1], hex[2])
   ]]

        local delta = 3
        local smaller, bigger = newHexPolygon(cx, cy, rad + delta), newHexPolygon(cx, cy, rad + delta)
        addVertex2(array, smaller[1], smaller[2])
        addVertex2(array, bigger[3], bigger[4])
        addVertex2(array, smaller[3], smaller[4])
    end

    local result = {}
    local mesh = gr.newMesh((6 * 3 + 6 * 6) * xcount * ycount, "triangles", "dynamic")
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
            addBorder(meshData, last)
            last:setMesh(mesh, lastIndex)

            cx = cx + w
        end
        cy = cy + h * 3 / 4
        cx = j % 2 == 1 and startcx + w / 2 or startcx
    end

    mesh:setVertices(meshData)

    return result, mesh
end

