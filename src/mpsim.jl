function getmpmeasurements(recpos, svpos, walls)
    # This function computes the multipath measurements for the receiver
    # recpos: receiver position in ENU frame
    # svpos: satellite positions in ENU frame
    # walls: list of walls (tupple of line segments) in ENU frame
    # wallheights: list of wall heights in ENU frame

    measurements = zeros(length(svpos))u"m" # measurements for each satellite
    mode = zeros(Int, length(svpos)) # 0: LOS, 1: MPATH, 2: NO LOS or MPATH

    projections = [mirror(wall, recpos) for wall in walls] # project the receiver through each wall

    for svid in eachindex(svpos)
        # check if los exists
        losss = false # Not available
        numpaths = 0
        if islos(svpos[svid], recpos, walls)
            distances = [norm(recpos - svpos[svid])]
            amplitudes = [1.0]
            numpaths += 1
            losss = true # LOS available
        else
            distances = []
            amplitudes = []
        end


        for projid in eachindex(projections)
            if norm(recpos - pointify(walls[projid])[1]) > 200u"m" # skip walls that are very far away...
                continue # skip this projection
            end

            if (norm(svpos[svid] - projections[projid]) - norm(recpos - svpos[svid]) > 0u"m") && norm(svpos[svid] - projections[projid]) - norm(recpos - svpos[svid]) < 30u"m" && cangettoreceiver(recpos, projections[projid], projid, svpos[svid], walls)
                numpaths += 1
                θ = incidenceangle(walls[projid], Ray(projections[projid], svpos[svid]-projections[projid]); unit = :rad) - pi/2 # incidence angle
                push!(distances, norm(svpos[svid] - projections[projid]))   # distance from the receiver to the projection point
                # Schlick formula for the amplitude of the reflected signal
                r0 = ((3-1)/(1+3))^2
                power = r0 + (1-r0) * (1-cos(θ))^5
                push!(amplitudes, power)                              
            end
        end

        if length(distances) > 1
            amplitudes[distances .> min(distances...) + 20u"m"] .= 0.0 # Remove rays that would likely be detected by the correlator
        end

        if numpaths == 0
            mode[svid] = :blocked # NO LOS or MPATH
            measurements[svid] =  0u"m"
        elseif (numpaths == 1) && losss
            mode[svid] = :los # LOS only
            measurements[svid] = distances[1]
        elseif (numpaths > 1) && losss
            mode[svid] = :multipath # MP
            measurements[svid] = sum(distances .* amplitudes) / sum(amplitudes)
        elseif (numpaths > 0) && !losss
            mode[svid] = :nlos # NLOS
            measurements[svid] = sum(distances .* amplitudes) / sum(amplitudes)
        else
            measurements[svid] = sum(distances .* amplitudes) / sum(amplitudes)
        end        
    end
    return measurements, mode
end

