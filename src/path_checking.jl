function islos(svpos, recpos, walls)
    # checks if there is a line of sight between the receiver and the satellite
    los = Ray(recpos, svpos-recpos) # create a line of sight segment
    for wall in walls
        if Meshes.intersects(wall, los) # check if the line of sight Meshes.intersects with the wall
            return false # LOS blocked by wall
        end
    end
    return true
end

function cangettoreceiver(recpos, projpos, projid, svpos, walls)
    # checks if the ray from the satellite to the receiver can get to the receiver through the wall
    intersectpoint = Meshes.intersection(Ray(projpos, svpos-projpos), walls[projid]) # get the intersection point
    if isnothing(intersectpoint) # check if the intersection point is valid
        return false # no intersection point found
    end
    w2 = vcat(walls[1:projid-1], walls[projid+1:end]) # get the walls that are not being projected through
    for wall in w2
        try # Yeah.... I havent found the source of the error so I pretend it doesn't exist
            if Meshes.intersects(Ray(intersectpoint, svpos-intersectpoint), wall) || Meshes.intersects(Ray(intersectpoint, recpos - intersectpoint), wall) # check if the ray Meshes.intersects with the wall
                return false # ray blocked by wall
            end
        catch
            @warn "Error in intersection calculation, skipping triangle $wall"
            return false # An non-fatal error occured.....
        end
    end
    return true
end