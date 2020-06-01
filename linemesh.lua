
local gr = love.graphics
local mesh = gr.newMesh(6, "strip", "dynamic")
local vec = require "vector"

function init()
end

function drawLine(x1, y1, x2, y2)
    function addVertex(array, x, y)
        table.insert(array, {
            x, y,
            0, 0,
            1, 1, 1, 1,
        })
    end
--[[
   [
   [    local vertices = {}
   [    local len = dist(x1, y1, x2, y2)
   [    local dirx, diry = (x2 - x1) / len, (y2 - y1) / len
   [    local width = 10
   [    local p1x, p1y = x1 + dirx * width, y1 + -diry * width
   [    local p2x, p2y = x1 + dirx * width, y1 + -diry * width
   [    local p3x, p3y = x2 + -dirx * width, y2 + diry * width
   [    local p4x, p4y = x2 + -dirx * width, y2 + diry * width
   ]]

    local vertices = {}
    local len = dist(x1, y1, x2, y2)
    local dirx, diry = vec(x2 - x1) / len, vec(y2 - y1) / len
    local dir1, dir2 = vec(x2 - x1, y2 - y1) / len, vec(x1 - x2, y1 - y2) / len

    local width = 10
    local p1 = vec(x1, y1) + dir1:perpendicular() * width
    local p2 = vec(x1, y1) + dir2:perpendicular() * width
    local p3 = vec(x2, y2) + dir1:perpendicular() * width
    local p4 = vec(x2, y2) + dir2:perpendicular() * width

    local prevColor = {gr.getColor()}

    gr.setPointSize(3)
    --gr.points(p1x, p1y, p2x, p2y, p3x, p3y, p4x, p4y)
    gr.points(p1.x, p1.y, p2.x, p2.y, p3.x, p3.y, p4.x, p4.y)

    gr.setColor{1, 0, 0}
    gr.points(x1, y1, x2, y2)

    mesh:setVertices(vertices)
    gr.setColor(prevColor)
    gr.draw(mesh)

    gr.line(x1, y1, x2, y2)
end

return {
    init,
    drawLine = drawLine,
}
