# Implements functions that fix bugs in the Meshes package
# Maybe I just misunderstood the package... 
# Anyway, if you have a better solution, please let me know
# Like.... seriously, I don't know if this is the right way to do it



# Calling intersect sometimes throws error 
# "center(::Ray) not defined"
# This is a workaround... maybe gives wrong results, 
# but at least it doesn't crash
function Meshes.center(r::Ray)
    return r.p
end


# Noticed that the original intersection function 
# doesn't work for quadrangles (WHY???)
# Well so I just split the quadrangle into two triangles
function Meshes.intersects(r::Ray, q::Quadrangle)
    pts = pointify(q) # get the points of the quadrangle
    return Meshes.intersects(Meshes.Triangle(pts[1], pts[2], pts[3]), r) || Meshes.intersects(Meshes.Triangle(pts[1], pts[3], pts[4]), r) # check if the ray Meshes.intersects with the quadrangle
end

function Meshes.intersects(q::Quadrangle, r::Ray)
    return Meshes.intersects(r,q) # check if the ray Meshes.intersects with the triangle
end

# Same as above with the intersection function
function Meshes.intersection(r::Ray, q::Quadrangle)
    pts = pointify(q) # get the points of the quadrangle
    i1 = intersection(r, Meshes.Triangle(pts[1], pts[2], pts[3])) # check if the ray Meshes.intersects with the triangle
    if !isnothing(i1.geom) # check if the intersection point is valid
        return i1.geom # get the first intersection point
    else
        i2 = intersection(r, Meshes.Triangle(pts[1], pts[3], pts[4])) # check if the ray Meshes.intersects with the triangle
        if !isnothing(i2.geom) # check if the intersection point is valid
            return i2.geom # get the first intersection point
        else
            return nothing # no intersection point found
        end
    end
end

function Meshes.intersection(q::Quadrangle, r::Ray)
    return intersection(r,q) # check if the ray Meshes.intersects with the triangle
end

