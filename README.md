![Codine Development Syphoning Script Banner](https://i.imgur.com/EIzeqjY.png)

### CDN-Syphoning

Gas prices too high? Don't want to buy your own gas? Just steal it! CDN-Syphoning adds syphoning functionality based off an item. The way players get this item is up to you! Players will use the item next to vehicles and be able to steal the gas from the vehicle, or refuel the vehicle with the gas they obtained from syphoning.

### Dependencies:

- [qb-menu](https://github.com/qbcore-framework/qb-menu)
- [qb-input](https://github.com/qbcore-framework/qb-input)

<br>
<br>

![Codine Development Syphoning Script Install Banner](https://i.imgur.com/QI6GHDB.png)

### Begin your installation

Here, we shall provide a step-by-step guide on installing cdn-syphoning to your server! Trust us, it is super quick, so don't worry! We know following instructions that are written down can be confusing, so we included some helpful install gifs below!

### Step 1:

First, we will start by downloading the repository. Once downloaded, renamed the resource from *cdn-syphoning-main* to just *cdn-syphoning*.
<br> <br> 
Then, we will drag it into our resources folder. We recommend putting it in your qb directory or standalone. 
<br> <br> 

![step 1](https://i.imgur.com/bVQl0cb.gif)

### Step 2:

Next, we're going to get the item added into our server! This is fairly simple.
<br> <br> 
_Copy and Paste the following into your items.lua in QB-Core/Shared/items.lua_
<br>
**If you have the decay system setup, add the necessary compenents for that as well!**
```
["syphoningkit"]				 = {["name"] = "syphoningkit", 					["label"] = "Syphoning Kit", 			["weight"] = 5000, 		["type"] = "item", 		["image"] = "syphoningkit.png", 		["unique"] = true, 		["useable"] = true, 	["shouldClose"] = false,   ["combinable"] = nil,   ["description"] = "A kit made to siphon gasoline from vehicles."},
```
![step 2](https://i.imgur.com/t1TyS8W.gif)


Next, we will add the image, located @ _cdn-syphoning/assets/syphoningkit.png_ into your images folder in your inventory resource!
<br> <br>

**Drag _or_ CTRL+X the syphoningkit.png to the following directory: _inventoryname/html/images_**
![step 2 images](https://i.imgur.com/P9WbcMK.gif)

### Step 3:

Lastly, we need to get proper formatting for our itemData in the qb-inventory! If using another inventory such as LJ-Inventory, the process should be that same.
<br> <br> 
We want to navigate to our app.js in your inventory resource. This is usually located here: *inventoryname*/html/js/app.js*
<br> <br> 
Once you have opened the app.js, hit CTRL+F, and search for the following string: 
<br> 
```
} else if (itemData.name == "harness") {
```
Once you have found this line, copy the following one line above it:
<br> 
```
        } else if (itemData.name == "syphoningkit") { // Syphoning Kit (CDN-Fuel or CDN-Syphoning!)
            $(".item-info-title").html("<p>" + itemData.label + "</p>");
            $(".item-info-description").html(
                "<p>" + "A kit used to syphon gasoline from vehicles! <br><br>" + itemData.info.gasamount + " Liters Inside.</p>" +
                "</span></p><p style=\"padding-top: .8vh;font-size:11px\"><b>Weight: </b>" + ((itemData.weight * itemData.amount) / 1000).toFixed(1) + " | <b>Amount: </b> " + itemData.amount
            );
```
**If using decay, you must add the quality part at the end yourself!**

<br> <br> 
You can also follow this GIF to better understand the process!

![step 3](https://i.imgur.com/2qMuyJm.gif)


### Step 4: 

Lastly, we will ensure the resource in our server.cfg. This is only neccessary if it is not in a directory that has been ensured already. 
<br> <br>
_To ensure, just add this into your server.cfg:_
```
ensure cdn-syphoning
```
### Optional Step 5:

If you wish, we have preconfigured an item for the qb-shops config, you can use this to add the syphoningkit to your shops or add it yourself:
```
        [10] = {
            name = "syphoningkit",
            price = 5000,
            amount = 5,
            info = { gasamount = 0 },
            type = "item",
            slot = 10,
        }, -- Example for Required Job 
```
You will most likely have to change the slot it is in for it to work properly!
<br><br>
![Codine Development Syphoning Script Features Banner](https://i.imgur.com/9jc8tll.png)

#### Some features to mention within this cdn-syphoning

- Configurable Maximum amount for the Syphoning Kit!
- Easily Configurable Animations!
- Built in Debug Mode in case you want to make changes!
- Configurable Police Notifications

<br>
<br>

![Codine Development Syphoning Script Showcase Banner](https://i.imgur.com/34Mu0fi.png)

### Demonstration of the script

Here's a video showcasing the script in action!

[Click Here to Watch the Video!](https://youtu.be/2CJjM_9hmNA)

<br>
<br>

![Codine Development Syphoning Script Future Plans banner](https://i.imgur.com/Ide300v.png)

### Future Plans

- Implement into our [cdn-fuel](https://github.com/CodineDev/cdn-fuel) as a Config option!
- Send other suggestions in our discord server! Link below!

<br>
<br>

![Codine Development Links Banner](https://i.imgur.com/TSfy7ik.png)

### Codine Links

- [Discord](https://discord.gg/Ta6QNnuxM2)
- [Tebex](https://codine.tebex.io/)
- [Youtube](https://www.youtube.com/channel/UC3Nr0qtyQP9cGRK1m25pOqg)
