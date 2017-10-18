-- GeoRegion Verification
-- Get a list of hotels in a Region, and add the most common filtering attributes
--

SELECT  regioneanhotelidmapping.EANHotelID,activepropertybusinessmodel.Name,activepropertybusinessmodel.Address1,activepropertybusinessmodel.City,
 activepropertybusinessmodel.Country,activepropertybusinessmodel.StarRating,activepropertybusinessmodel.PropertyCategory,propertytypelist.PropertyCategoryDesc,activepropertybusinessmodel.BusinessModelMask
FROM regioneanhotelidmapping
JOIN activepropertybusinessmodel ON regioneanhotelidmapping.EANHotelID = activepropertybusinessmodel.EANHotelID
JOIN propertytypelist ON activepropertybusinessmodel.PropertyCategory = propertytypelist.PropertyCategory
	WHERE regioneanhotelidmapping.RegionID =  6053149

	

