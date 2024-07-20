function AddTargetEntity(entity, options)
    if Config.Target == 'ox' then
        exports.ox_target:addLocalEntity(entity, options)
    elseif Config.Target == 'qb-target' then
        exports['qb']:AddTargetEntity(entity, {
            options = options,
            distance = 2.0
        })
    elseif Config.Target == 'interact' then
        exports.interact:AddLocalEntityInteraction({
            entity = entity,
            id = 'status',
            ignoreLos = true,
            distance = 4.0,
            interactDst = 1.3,
            options = options
        })
    end
end