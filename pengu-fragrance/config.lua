Config = {}

Config = {
    Target = 'qb',                                 -- Options: 'qb' or 'ox' or 'qtarget'
    Menu = 'ox',                                   -- Options: 'ox' or 'qb' or 'none'
    ProgressBar = 'ox',                            -- Options: 'progressbar' or 'ox'
    InventoryType = 'qb',                         -- Options: 'qb' or 'ox' or 'ps'
    ShopLocation = vector4(53.08, -1348.61, 29.29, 222.79), -- Location of the shop
    ShowBlip = true,                               -- Show the blip on the map
    Debug = true,                                  -- Debug mode

    ShopBlip = {
        coords = vector3(54.55, -1347.25, 29.3),
        sprite = 402,
        color = 2,
        scale = 1.0,
        name = 'Fragrance Shop',
    },
    NPC = {
        model = 'a_m_m_business_01',
        coords = vector4(53.08, -1348.61, 29.29, 222.79),
    },
    Shop = {
        {
            Name = 'Fragrance',
            Items = {
                {
                    Name = 'Perfume',
                    Price = 100,
                    Type = 'item',
                    Item = 'perfume',
                },
                {
                    Name = 'Cologne',
                    Price = 100,
                    Type = 'item',
                    Item = 'cologne',
                },
                {
                    Name = 'Deodorant',
                    Price = 100,
                    Type = 'item',
                    Item = 'deodorant',
                },
            }
        }
    }
}
