require "snippets"
local inspect = require "inspect"
local gr = love.graphics

function dist(x1, y1, x2, y2) 
    return ((x2 - x1) ^ 2 + (y2 - y1) ^ 2) ^ 0.5 
end

function genHexPolygon(cx, cy, rad)
    local hex = {}

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

function genHexField(startcx, startcy, xcount, ycount, rad)
    local result = {}
    local cx, cy = startcx, startcy
    local hasWH = false
    local w, h
    for j = 1, ycount do
    for i = 1, xcount do
        table.insert(result, genHexPolygon(cx, cy, rad))
        if not hasWH then
            w, h = getHexPolygonWidth(result[#result]), 
                getHexPolygonHeight(result[#result])
        end
        cx = cx + w
    end
        cy = cy + h * 3 / 4
        cx = j % 2 == 1 and startcx + w / 2 or startcx
    end
    return result
end

local hex = genHexPolygon(100, 100, 50)
local hexRad = 50
local hexField = genHexField(80, 80, 200, 200, hexRad)
local hexHeight = getHexPolygonHeight(hex)
local hexWidth = getHexPolygonWidth(hex)

function drawHexField(field)
    local prevColor = {gr.getColor()}
    local alpha = prevColor[4]
    local w, h = gr.getDimensions()
    for k, v in pairs(field) do
        if v.cx + hexRad < w or v.cy + hexRad < h then
            if v.selected then
                gr.setColor{1, 0, 0, alpha}
            else
                gr.setColor(prevColor)
            end
            gr.polygon("fill", v)
            gr.setColor{0, 0, 0, alpha}
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
    gr.setColor{0, 0.85, 0.1, 0.5}

    --local w, h = gr.getDimensions()
    --gr.setScissor(0, 0, w / 2, h / 2)
    drawHexField(hexField)

    gr.setColor{1, 1, 1, 1}
    gr.print(string.format("FPS %d", love.timer.getFPS()))
end

function updateSelectedItem(x, y)
    for k, v in pairs(hexField) do
        if pointInPolygon(v, x, y) then
            v.selected = true
        else
            v.selected = false
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
