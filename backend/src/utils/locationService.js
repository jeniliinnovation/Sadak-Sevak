const Area = require('../models/Area');
const { Op } = require('sequelize');

/**
 * SARA - Smart Area Road Assessment Utility
 * This service enriches raw coordinates with structured area data from the Database.
 */

/**
 * Enriches location data based on coordinates by querying the Database.
 * @param {number} lat 
 * @param {number} lng 
 * @returns {Promise<object>} Enriched location object
 */
const enrichLocation = async (lat, lng) => {
  let detectedZone = 'Unknown Zone';
  let detectedWard = 'Unknown Ward';
  let detectedArea = 'General Area';

  try {
    // Query database for an area that contains these coordinates
    const area = await Area.findOne({
      where: {
        latMin: { [Op.lte]: lat },
        latMax: { [Op.gte]: lat },
        lngMin: { [Op.lte]: lng },
        lngMax: { [Op.gte]: lng },
        isActive: true
      }
    });

    if (area) {
      detectedZone = area.zoneName;
      detectedWard = area.wardName;
      detectedArea = `${detectedZone} - ${detectedWard}`;
    }
  } catch (error) {
    console.error('Error during SARA enrichment:', error);
  }

  return {
    lat: lat,
    lng: lng,
    zone: detectedZone,
    ward: detectedWard,
    area: detectedArea,
    address: `Verified location near Rajkot (${lat.toFixed(4)}, ${lng.toFixed(4)})`,
    fullAddress: `Verified location near Rajkot (${lat.toFixed(4)}, ${lng.toFixed(4)})`,
    timestamp: new Date()
  };
};

module.exports = { enrichLocation };
