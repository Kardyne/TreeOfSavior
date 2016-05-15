local config = {
	--Colors
	not_found = "FFFF0000",
	found = "FF00FF00",
	completed = "FF0000FF",
	--Other parameters
	size = 50;
}


function Strip_Control_Codes(str)
    local s = "";
    for i in str:gmatch( "%C+" ) do
		s = s .. i;
    end
    return s;
end

function MAP_OPEN_HOOKED(frame)

	_G["MAP_OPEN_OLD"](frame);
	COLLECTION_DRAW(frame);
	
end

function COLLECTION_DRAW(frame)
	
	--Get position of map completion text
	local rateObj = GET_CHILD(frame, "rate", 'ui::CRichText');
	local xPos = rateObj:GetX() + rateObj:GetWidth();
	local yPos = rateObj:GetY();
	
	--Retrieve the item icon
	local itemClass = GetClass('Item', "COLLECT_118");
	local imageName = GET_ITEM_ICON_IMAGE(itemClass);
	
	--Create the image
	local pic = frame:CreateOrGetControl("picture", "_COLLECTION_", xPos, yPos, config.size, config.size);
	tolua.cast(pic, "ui::CPicture");

	pic:SetImage(imageName);
	pic:SetEnableStretch(1);
	
	local coll = COLLECTION_FOUND()
	
	--Set color tone based on the collection status
	if coll == nil then
		pic:SetColorTone(config.not_found); --red
		pic:SetTextTooltip("You have not found the collection item for this map.");
	else
		--Add the tooltip for the collection
		local curCount, maxCount = GET_COLLECTION_COUNT(coll.type, coll);
		if curCount >= maxCount then
			pic:SetColorTone(config.found);
			pic:SetTextTooltip("You have found and completed the collection for this map.");
		else
			pic:SetColorTone(config.completed); --blue
			pic:SetTextTooltip("You have found but not completed the collection for this map.");
		end
		--TODO: Add a nice tooltip (ie. one with the collection window)
		-- TOOLTIP(frame, coll)
	end
	
	--Show it
	pic:ShowWindow(1);
	
end

function COLLECTION_FOUND()
	
	--Retrieve the map name
	local internalMapName = session.GetMapName();
	local dictionaryMapName = GetClass("Map", internalMapName).Name;
	local mapName = dictionary.ReplaceDicIDInCompStr(dictionaryMapName);
	
	--List the collections the pc has	
	local pc = session.GetMySession();
	local colls = pc:GetCollection();
	
	--Check every collection that the pc possesses
	local cnt = colls:Count();
	for i = 0 , cnt - 1 do
		local coll = colls:GetByIndex(i);
		local clsName = GetClassByType("Collection", coll.type).Name;
		local cleanName = Strip_Control_Codes(string.sub(clsName, 13));
		
		--Test if the collection matches the map
		if (cleanName == mapName) then
			return coll;
		end
	end
	
	return nil;
	
end

SETUP_HOOK(MAP_OPEN_HOOKED, "MAP_OPEN");

ui.SysMsg("Map Collection Check loaded!");
