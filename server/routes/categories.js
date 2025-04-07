const express = require('express');
const router = express.Router();
const { v4: uuidv4 } = require('uuid'); // You might use a different ID strategy here
const fileUtils = require('../utils/file-utils');

const DATA_FILE = 'categories.json';

// GET all categories
router.get('/', async (req, res) => {
  try {
    const categories = await fileUtils.readFile(DATA_FILE);
    res.json(categories);
  } catch (error) {
    res.status(500).json({ error: 'Failed to retrieve categories' });
  }
});

// GET a single category by ID
router.get('/:id', async (req, res) => {
  try {
    const categories = await fileUtils.readFile(DATA_FILE);
    const category = categories.find(cat => cat.categoryId === req.params.id);
    if (!category) {
      return res.status(404).json({ error: 'Category not found' });
    }
    res.json(category);
  } catch (error) {
    res.status(500).json({ error: 'Failed to retrieve category' });
  }
});

// POST a new category
router.post('/', async (req, res) => {
  try {
    const categories = await fileUtils.readFile(DATA_FILE);

    if (!req.body.name) {
      return res.status(400).json({ error: 'Missing required field: name' });
    }

    const newCategory = {
      categoryId: req.body.categoryId || uuidv4(), // Allow client-provided ID or generate one
      name: req.body.name,
    };
    categories.push(newCategory);
    await fileUtils.writeFile(DATA_FILE, categories);
    res.status(201).json(newCategory);
  } catch (error) {
    res.status(500).json({ error: 'Failed to create category' });
  }
});

// PUT (update) an existing category
router.put('/:id', async (req, res) => {
  try {
    const categories = await fileUtils.readFile(DATA_FILE);
    const categoryIndex = categories.findIndex(cat => cat.categoryId === req.params.id);
    if (categoryIndex === -1) {
      return res.status(404).json({ error: 'Category not found' });
    }

    categories[categoryIndex] = { ...categories[categoryIndex], ...req.body };
    await fileUtils.writeFile(DATA_FILE, categories);
    res.json(categories[categoryIndex]);
  } catch (error) {
    res.status(500).json({ error: 'Failed to update category' });
  }
});

// DELETE a category
router.delete('/:id', async (req, res) => {
  try {
    const categories = await fileUtils.readFile(DATA_FILE);
    const categoryIndex = categories.findIndex(cat => cat.categoryId === req.params.id);
    if (categoryIndex === -1) {
      return res.status(404).json({ error: 'Category not found' });
    }

    //  Check if any subcategories are using this category (or objects, if applicable)
    //  This is important for data integrity!  You'll need to implement this check.

    categories.splice(categoryIndex, 1);
    await fileUtils.writeFile(DATA_FILE, categories);
    res.status(204).send();
  } catch (error) {
    res.status(500).json({ error: 'Failed to delete category' });
  }
});

module.exports = router;