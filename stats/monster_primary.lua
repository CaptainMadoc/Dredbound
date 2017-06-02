function applyDamageRequest(damageRequest)
  if world.getProperty("nonCombat") then
    return {}
  end

  local damage = 0
  if damageRequest.damageType == "Damage" or damageRequest.damageType == "Knockback" then
    damage = damage + root.evalFunction2("protection", damageRequest.damage, status.stat("protection"))
  elseif damageRequest.damageType == "IgnoresDef" then
    damage = damage + damageRequest.damage
  end

  if status.resourcePositive("shieldHealth") then
    local shieldAbsorb = math.min(damage, status.resource("shieldHealth"))
    status.modifyResource("shieldHealth", -shieldAbsorb)
    damage = damage - shieldAbsorb
  end

  if damage > 0 and damageRequest.damageType ~= "Knockback" then
    status.modifyResource("health", -damage)
  end

  status.addEphemeralEffects(damageRequest.statusEffects)

  local knockbackFactor = (1 - status.stat("grit")) * (damage / status.resourceMax("health"))

  local knockbackMomentum = damageRequest.knockbackMomentum
  knockbackMomentum[1] = knockbackMomentum[1] * knockbackFactor
  knockbackMomentum[2] = knockbackMomentum[2] * knockbackFactor
  mcontroller.addMomentum(knockbackMomentum)

  return {{
    sourceEntityId = damageRequest.sourceEntityId,
    targetEntityId = entity.id(),
    position = mcontroller.position(),
    damage = damage,
    kind = "Normal",
    damageSourceKind = damageRequest.damageSourceKind,
    targetMaterialKind = status.statusProperty("targetMaterialKind"),
    killed = not status.resourcePositive("health")
  }}
end
