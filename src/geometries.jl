function vec2pt(vec, pttype, coords::Cartesian3D{T}) where T
    return GeoStats.Point{pttype}(Cartesian3D{T}(vec...))
end

function mirror(wall, recpos::GeoStats.Point{T}) where T
    pts = pointify(wall)
    v1 = pts[2] - pts[1]
    v2 = pts[3] - pts[1]

    n = cross(v1, v2)
    n = n / norm(n)
    
    v2p = recpos - pts[1]
    dist = v2p.coords[1].val *n[1] + v2p.coords[2].val * n[2] + v2p.coords[3].val * n[3]

    mir = recpos - GeoStats.Point((2 * dist * n)...)
    return vec2pt(mir, T, recpos.coords)
end




function incidenceangle(triangle, ray; unit = :rad)
    # calculates the incidence angle of the ray on the triangle
    # triangle: a tuple of three points (vertices) of the triangle
    # ray: a line segment from the receiver to the satellite
    # returns the angle

    # get the normal vector of the triangle
    triangle = pointify(triangle) # convert to Point objects
    n = cross(triangle[2] - triangle[1], triangle[3] - triangle[1])
    n = normalize(n)

    # get the direction vector of the ray
    d = normalize(ray.v)

    # calculate the angle between the normal and the direction vector
    if unit == :rad
        angle = acos(dot(n, d))
    elseif unit == :deg   
        angle = acos(dot(n, d)) * 180 / π
    else 
        error("Invalid unit. Use :rad or :deg.")
    end
    return angle
end