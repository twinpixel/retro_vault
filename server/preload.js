const axios = require('axios');
const fs = require('fs');

const API_BASE_URL = 'http://localhost:3000'; // Adjust if needed

async function preloadData() {
  try {
    const data = JSON.parse(fs.readFileSync('data.json', 'utf8'));

    // 1. Create Categories
    const categoryMap = {}; // To store category IDs for subcategories
    for (const category of data.categories) {
      const response = await axios.post(`${API_BASE_URL}/categories`, category);
      categoryMap[category.name.toLowerCase()] = response.data.categoryId;
      console.log(`Created category: ${category.name}`);
    }

    // 2. Create Subcategories
    for (const subcategory of data.subcategories) {
      const categoryId = categoryMap[subcategory.categoryId.toLowerCase()];
      if (categoryId) {
        await axios.post(`${API_BASE_URL}/subcategories`, { ...subcategory, categoryId });
        console.log(`Created subcategory: ${subcategory.name}`);
      } else {
        console.warn(`Skipped subcategory: ${subcategory.name} - Category not found`);
      }
    }

    // 3. Create Acquisitions
    const acquisitionMap = {}; // To store acquisition IDs for objects
    for (const [index, acquisition] of data.acquisitions.entries()) {
      const response = await axios.post(`${API_BASE_URL}/acquisitions`, acquisition);
      acquisitionMap[`acquisition_${index + 1}`] = response.data.acquisitionId;
      console.log(`Created acquisition: ${acquisition.sourceOfAcquisition}`);
    }

    // 4. Create Objects
    const objectMap = {}; // To store object IDs for exhibit groupings
    for (const [index, object] of data.objects.entries()) {
      const acquisitionId = acquisitionMap[object.acquisitionId];
      if (acquisitionId) {
        const response = await axios.post(`${API_BASE_URL}/objects`, { ...object, acquisitionId });
        objectMap[`object_${index + 1}`] = response.data.uniqueId;
        console.log(`Created object: ${object.nameTitle}`);
      } else {
        console.warn(`Skipped object: ${object.nameTitle} - Acquisition not found`);
      }
    }

    // 5. Create Exhibit Groupings
    for (const exhibitGrouping of data.exhibitGroupings) {
      const objectIds = exhibitGrouping.objectIds.map(id => objectMap[id]).filter(Boolean); // Filter out any undefined objectIds
      await axios.post(`${API_BASE_URL}/exhibit-groupings`, { ...exhibitGrouping, objectIds });
      console.log(`Created exhibit grouping: ${exhibitGrouping.name}`);
    }

    console.log('Data preload completed successfully!');

  } catch (error) {
    console.error('Error preloading data:', error.message);
    if (error.response) {
      console.error('Response data:', error.response.data);
    }
  }
}

preloadData();