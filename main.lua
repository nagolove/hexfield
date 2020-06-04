require "snippets"
require "hex"
local cam = require "camera".new()
local inspect = require "inspect"
local tween = require "tween"
local gr = love.graphics

local hexRad = 350
local hexColor = {0.5, 0.6, 1, 1}
local activeHexColor, passiveHexColor = {0.85, 0, 0, 1}, {0.5, 0.6, 0, 1}
--local hexField, hexMesh = newHexField(80, 80, 300, 300, hexRad, passiveHexColor)
local hexField, hexMesh = newHexField(380, 380, 1, 1, hexRad, passiveHexColor)

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
    --gr.scale(0.05, 0.05)
    --gr.rotate(0.3)

    gr.draw(hexMesh)

    gr.setColor{0, 0.85, 0.1, 0.5}
    --drawHexField(hexField)

    gr.pop()
    
    gr.setColor{1, 1, 1, 1}
    gr.print(string.format("FPS %d", love.timer.getFPS()))

    local drawLine = require "linemesh".drawLine
    local cx, cy = gr.getWidth() / 2, gr.getHeight() / 2
    local mx, my = love.mouse.getPosition()
    drawLine(cx, cy, mx, my)
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
    --updateSelectedItem(x, y)
end

love.update = function(dt)
end

love.keypressed = function(_, k, isrepeat)
    if k == "escape" then
        love.event.quit()
    end
end
