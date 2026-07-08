run(function()
    local LootTP
    local Height
    local VelocityMultiplier
    local Network
    
    LootTP = vape.Categories.Utility:CreateModule({
        Name = 'LootTP',
        Function = function(callback)
            if callback then
                local items = collection('ItemDrop', LootTP)
                repeat
                    if entitylib.isAlive then
                        local localPosition = entitylib.character.RootPart.Position
                        
                        for _, v in items do
                            if tick() - (v:GetAttribute('ClientDropTime') or 0) < 2 then continue end
                            
                            -- Check if item is in the void (below a certain Y position, e.g., -100)
                            if v.Position.Y < -100 then
                                if isnetworkowner(v) and Network.Enabled and entitylib.character.Humanoid.Health > 0 then
                                    -- Launch item high into the sky
                                    local skyHeight = Height.Value
                                    local targetPosition = localPosition + Vector3.new(0, skyHeight, 0)
                                    
                                    -- Calculate upward velocity
                                    local direction = (targetPosition - v.Position).Unit
                                    local distance = (targetPosition - v.Position).Magnitude
                                    local velocity = direction * (distance * VelocityMultiplier.Value)
                                    
                                    -- Set velocity if the item has a humanoid or is a physics object
                                    if v:FindFirstChild('BodyVelocity') then
                                        v.BodyVelocity.Velocity = velocity
                                    elseif v:IsA('BasePart') then
                                        -- Try to apply velocity directly
                                        v.AssemblyLinearVelocity = velocity
                                    end
                                    
                                    -- Teleport item to the sky
                                    v.CFrame = CFrame.new(targetPosition)
                                end
                                
                                -- Bring it back to player once it's falling
                                if (localPosition - v.Position).Magnitude <= 50 and v.Position.Y < localPosition.Y then
                                    task.spawn(function()
                                        bedwars.Client:Get(remotes.PickupItem):CallServerAsync({
                                            itemDrop = v
                                        }):andThen(function(suc)
                                            if suc and bedwars.SoundList then
                                                bedwars.SoundManager:playSound(bedwars.SoundList.PICKUP_ITEM_DROP)
                                                local sound = bedwars.ItemMeta[v.Name].pickUpOverlaySound
                                                if sound then
                                                    bedwars.SoundManager:playSound(sound, {
                                                        position = v.Position,
                                                        volumeMultiplier = 0.9
                                                    })
                                                end
                                            end
                                        end)
                                    end)
                                end
                            end
                        end
                    end
                    task.wait(0.1)
                until not LootTP.Enabled
            end
        end,
        Tooltip = 'Teleports dropped items from the void back to you'
    })
    
    Height = LootTP:CreateSlider({
        Name = 'Sky Height',
        Min = 50,
        Max = 500,
        Default = 200,
        Suffix = function(val) 
            return val == 1 and 'stud' or 'studs' 
        end
    })
    
    VelocityMultiplier = LootTP:CreateSlider({
        Name = 'Velocity Multiplier',
        Min = 0.1,
        Max = 5,
        Default = 1.5,
        Decimal = 10
    })
    
    Network = LootTP:CreateToggle({
        Name = 'Network TP',
        Default = true
    })
end)
