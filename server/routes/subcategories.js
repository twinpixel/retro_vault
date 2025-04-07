const express = require('express');
const router = express.Router();
const { v4: uuidv4 } = require('uuid'); // You might use a different ID strategy here
const fileUtils = require('../utils/file-utils');

const DATA_FILE = 'subcategories.json';

// GET all subcategories
router.get('/', async (req, res) => {
  try {
    const subcategories = await fileUtils.readFile(DATA_FILE);
    res.json(subcategories);
  } catch (error) {
    res.status(500).json({ error: 'Failed to retrieve subcategories' });
  }
});

// GET a single subcategory by ID
router.get('/:id', async (req, res) => {
  try {
    const subcategories = await fileUtils.readFile(DATA_FILE);
    const subcategory = subcategories.find(sub => sub.subcategoryId === req.params.id);
    if (!subcategory) {
      return res.status(404).json({ error: 'Subcategory not found' });
    }
    res.json(subcategory);
  } catch (error) {
    res.status(500).json({ error: 'Failed to retrieve subcategory' });
  }
});

// POST a new subcategory
router.post('/', async (req, res) => {
  try {
    const subcategories = await fileUtils.readFile(DATA_FILE);

    if (!req.body.name || !req.body.categoryId) {
      return res.status(400).json({ error: 'Missing required fields: name and categoryId' });
    }

    const newSubcategory = {
      subcategoryId: req.body.subcategoryId || uuidv4(), // Allow client-provided ID or generate one
      name: req.body.name,
      categoryId: req.body.categoryId,
    };
    subcategories.push(newSubcategory);
    await fileUtils.writeFile(DATA_FILE, subcategories);
    res.status(201).json(newSubcategory);
  } catch (error) {
    res.status(500).json({ error: 'Failed to create subcategory' });
  }
});

// PUT (update) an existing subcategory
router.put('/:id', async (req, res) => {
  try {
    const subcategories = await fileUtils.readFile(DATA_FILE);
    const subcategoryIndex = subcategories.findIndex(sub => sub.subcategoryId === req.params.id);
    if (subcategoryIndex === -1) {
      return res.status(404).json({ error: 'Subcategory not found' });
    }

    subcategories[subcategoryIndex] = { ...subcategories[subcategoryIndex], ...req.body };
    await fileUtils.writeFile(DATA_FILE, subcategories);
    res.json(subcategories[subcategoryIndex]);
  } catch (error) {
    res.status(500).json({ error: 'Failed to update subcategory' });
  }
});

// DELETE a subcategory
router.delete('/:id', async (req, res) => {
  try {
    const subcategories = await fileUtils.readFile(DATA_FILE);
    const subcategoryIndex = subcategories.findIndex(sub => sub.subcategoryId === req.params.id);
    if (subcategoryIndex === -1) {
      return res.status(404).json({ error: 'Subcategory not found' });
    }

    //  Check if any objects are using this subcategory.
    //  This is crucial for data integrity! You'll need to implement this check.

    subcategories.splice(subcategoryIndex, 1);
    await fileUtils.writeFile(DATA_FILE, subcategories);
    res.status(204).send();
  } catch (error) {
    res.status(500).json({ error: 'Failed to delete subcategory' });
  }
});

module.exports = router;