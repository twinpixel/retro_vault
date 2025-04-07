const fs = require('fs').promises;
const path = require('path');

const dataDir = path.join(__dirname, '../data');

const readFile = async (filename) => {
  const filePath = path.join(dataDir, filename);
  try {
    const data = await fs.readFile(filePath, 'utf8');
    return JSON.parse(data);
  } catch (error) {
    // If the file doesn't exist, return an empty array
    if (error.code === 'ENOENT') {
      return [];
    }
    throw error;
  }
};

const writeFile = async (filename, data) => {
  const filePath = path.join(dataDir, filename);
  await fs.writeFile(filePath, JSON.stringify(data, null, 2), 'utf8');
};

module.exports = {
  readFile,
  writeFile,
};