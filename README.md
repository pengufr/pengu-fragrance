# Pengu Fragrance Script for QBCore Servers

### **Enhance your server with an immersive fragrance experience for players!**

---

## 🚀 Features

- **Fragrance Purchase**: Players can buy a variety of fragrances from a dedicated shop.
- **Fragrance Application**: Players can use fragrances to create a unique scent experience.
- **Dynamic Notifications**: Nearby players receive notifications when someone uses a fragrance.
- **Inventory Integration**: Seamless compatibility with different inventory systems (qb, ox, ps).
- **NPC Interaction**: Buy fragrances from an NPC at a specified location.
- **Progress Indicators**: Visual feedback during purchase and application processes.
- **Custom Configuration**: Easily adjust settings and items in the config file.

---

## ⚙️ Dependencies

- [qb-core](https://github.com/qbcore-framework/qb-core)
- [ox_lib](https://github.com/overextended/ox_lib)
- [qb-target](https://github.com/qbcore-framework/qb-target)
- [qb-menu](https://github.com/qbcore-framework/qb-menu)
- [progressbar](https://github.com/qbcore-framework/progressbar)

### Optional Dependencies
- [qtarget](https://github.com/overextended/qtarget/releases)
- [ox_target](https://github.com/overextended/ox_target)


---

## 🛠️ Installation Guide | v1.0.0

1. **Import the SQL**: Import the SQL file located in `sql/fragrance.sql` to your database.

2. **Add Fragrance Items to qb-core**:
    In `qb-core/shared/items.lua`, add:
    ```lua
    ['fragrance_name'] = { 
        ['name'] = 'fragrance_name', 
        ['label'] = 'Fragrance Name', 
        ['weight'] = 1, 
        ['type'] = 'item', 
        ['image'] = 'fragrance_name.png', 
        ['unique'] = true, 
        ['useable'] = true, 
        ['shouldClose'] = true, 
        ['combinable'] = nil, 
        ['description'] = 'A lovely fragrance that lingers.' 
    },
    ```

3. **Update qb-inventory Config**:
    In `qb-inventory/config.lua`, add:
    ```lua
    ["fragrance_name"] = {
        ["name"] = "fragrance_name",
        ["label"] = "Fragrance Name",
        ["weight"] = 1,
        ["type"] = "item",
        ["image"] = "fragrance_name.png",
        ["unique"] = true,
        ["useable"] = true,
        ["shouldClose"] = true,
        ["combinable"] = nil,
        ["description"] = "A lovely fragrance that lingers."
    },
    ```

---

## 🎬 Preview

- **Coming Soon!**

---

## 💬 Support

For any questions or issues, feel free to reach out on Discord: **pengufr**

---
