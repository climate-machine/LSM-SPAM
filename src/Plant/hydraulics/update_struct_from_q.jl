# this function returns the end pressure for root struct
# flow in mol s^-1, p_end in MPa
function update_struct_from_q(any_struct::StructTreeRootLayer, flow::Number; p_ini::Number=Inf)
    if p_ini==Inf
        p_end = any_struct.p_ups
    else
        p_end = p_ini
    end

    # update the flow rate in the struct
    any_struct.q = flow

    # compute the pressure drop along the rhizosphere, note that p_end is corrected for minor change in surface tension
    a   = any_struct.soil_a
    m   = any_struct.soil_m
    n   = any_struct.soil_n
    k   = any_struct.k_rhiz
    k_s = get_relative_surface_tension(any_struct.t_soil)
    k_t = get_relative_viscosity(any_struct.t_soil)
    for i in 0:9
        if p_end<0
            shell_t = (1.0 / (1.0 + (a*(-p_end/k_s))^n)) ^ m
        else
            shell_t = 1.0
        end
        shell_f  = sqrt(shell_t) * (1.0 - (1.0-shell_t^(1.0/m)) ^ m) ^ 2.0
        shell_k  = k * shell_f * log(10.0) / log((10.0-0.9*i)/(10.0-0.9*(i+1))) / k_t
        dp       = flow / shell_k
        p_end   -= dp
    end

    # update the water potential at rhizosphere-root connection
    any_struct.p_rhiz = p_end

    # compute and update the pressure drop along the xylem
    for i in 1:length(any_struct.p_element)
        p_25   = min(any_struct.p_history[i], p_end / get_relative_surface_tension(any_struct.t_element[i]))
        k_25   = any_struct.k_element[i] * exp( -1.0 * (-p_25/any_struct.b) ^ (any_struct.c) )
        k      = k_25 / get_relative_viscosity(any_struct.t_element[i])
        p_end -= flow / k + 998.0 * 9.8 * any_struct.z_element[i] * 1E-6

        # update the values in each element
        if p_25<any_struct.p_history[i]
            any_struct.p_history[i] = p_25
        end
        any_struct.p_element[i] = p_end
    end

    # update the xylem pressure at the tree base
    any_struct.p_dos = p_end
end




# for stem struct
function update_struct_from_q(any_struct::StructTreeStem, flow::Number, p_ini::Number=Inf)
    if p_ini==Inf
        p_end = any_struct.p_ups
    else
        p_end = p_ini
    end

    # update the flow rate in the struct
    any_struct.q = flow

    # compute and update the pressure drop along the xylem
    for i in 1:length(any_struct.p_element)
        p_25   = min(any_struct.p_history[i], p_end / get_relative_surface_tension(any_struct.t_element[i]))
        k_25   = any_struct.k_element[i] * exp( -1.0 * (-p_25/any_struct.b) ^ (any_struct.c) )
        k      = k_25 / get_relative_viscosity(any_struct.t_element[i])
        p_end -= flow / k + 998.0 * 9.8 * any_struct.z_element[i] * 1E-6

        # update the values in each element
        if p_25<any_struct.p_history[i]
            any_struct.p_history[i] = p_25
        end
        any_struct.p_element[i] = p_end
    end

    # update the xylem pressure at the tree base
    any_struct.p_dos = p_end
end




# for leaf struct
function update_struct_from_q(any_struct::StructTreeLeaf, flow::Number, p_ini::Number=Inf)
    if p_ini==Inf
        p_end = any_struct.p_ups
    else
        p_end = p_ini
    end

    # compute and update the pressure drop along the xylem
    for i in 1:length(any_struct.p_element)
        p_25   = min(any_struct.p_history[i], p_end / get_relative_surface_tension(any_struct.t_element[i]))
        k_25   = any_struct.k_element[i] * exp( -1.0 * (-p_25/any_struct.b) ^ (any_struct.c) )
        k      = k_25 / get_relative_viscosity(any_struct.t_element[i])
        p_end -= flow / k + 998.0 * 9.8 * any_struct.z_element[i] * 1E-6

        # update the values in each element
        if p_25<any_struct.p_history[i]
            any_struct.p_history[i] = p_25
        end
        any_struct.p_element[i] = p_end
    end

    # update the xylem pressure at the tree base
    any_struct.p_dos = p_end
end