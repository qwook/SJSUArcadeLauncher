
Physical = class("Physical")

function Physical:shouldCollide(other)
    return true
end

function Physical:beginContact(other, contact)
end

function Physical:endContact(other, contact)
end

function Physical:preSolve(other, contact)
end

function Physical:postSolve(other, contact, normal, tangent)
end

return Physical
