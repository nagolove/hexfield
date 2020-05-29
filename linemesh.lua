
local gr = love.graphics
local mesh = gr.newMesh(6, "strip", "dynamic")

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

    local vertices = {}
    local len = dist(x1, y1, x2, y2)
    local dirx, diry = (x2 - x1) / len, (y2 - y1) / len
    local width = 10
    local p1x, p1y = x1 + dirx * width, y1 + -diry * width
    local p2x, p2y = x1 + dirx * width, y1 + -diry * width
    local p3x, p3y = x2 + -dirx * width, y2 + diry * width
    local p4x, p4y = x2 + -dirx * width, y2 + diry * width

    mesh:setVertices(vertices)
    gr.draw(mesh)

    gr.line(x1, y1, x2, y2)
end

return {
    init,
    drawLine = drawLine,
}
