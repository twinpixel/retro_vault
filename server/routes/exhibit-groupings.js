const express = require('express');
const router = express.Router();
const { v4: uuidv4 } = require('uuid');
const fileUtils = require('../utils/file-utils');

const DATA_FILE = 'exhibit-groupings.json';

// GET all exhibit groupings
router.get('/', async (req, res) => {
  try {
    const groupings = await fileUtils.readFile(DATA_FILE);
    res.json(groupings);
  } catch (error) {
    res.status(500).json({ error: 'Failed to retrieve exhibit groupings' });
  }
});

// GET a single exhibit grouping by ID
router.get('/:id', async (req, res) => {
  try {
    const groupings = await fileUtils.readFile(DATA_FILE);
    const grouping = groupings.find(group => group.groupingId === req.params.id);
    if (!grouping) {
      return res.status(404).json({ error: 'Exhibit grouping not found' });
    }
    res.json(grouping);
  } catch (error) {
    res.status(500).json({ error: 'Failed to retrieve exhibit grouping' });
  }
});

// POST a new exhibit grouping
router.post('/', async (req, res) => {
  try {
    const groupings = await fileUtils.readFile(DATA_FILE);

    if (!req.body.name || !req.body.description) {
      return res.status(400).json({ error: 'Missing required fields: name and description' });
    }

    const newGrouping = {
      groupingId: uuidv4(),
      name: req.body.name,
      description: req.body.description,
      objectIds: req.body.objectIds || [],  // Initialize with an empty array if not provided
    };
    groupings.push(newGrouping);
    await fileUtils.writeFile(DATA_FILE, groupings);
    res.status(201).json(newGrouping);
  } catch (error) {
    res.status(500).json({ error: 'Failed to create exhibit grouping' });
  }
});

// PUT (update) an existing exhibit grouping
router.put('/:id', async (req, res) => {
  try {
    const groupings = await fileUtils.readFile(DATA_FILE);
    const groupingIndex = groupings.findIndex(group => group.groupingId === req.params.id);
    if (groupingIndex === -1) {
      return res.status(404).json({ error: 'Exhibit grouping not found' });
    }

    groupings[groupingIndex] = { ...groupings[groupingIndex], ...req.body };
    await fileUtils.writeFile(DATA_FILE, groupings);
    res.json(groupings[groupingIndex]);
  } catch (error) {
    res.status(500).json({ error: 'Failed to update exhibit grouping' });
  }
});

// DELETE an exhibit grouping
router.delete('/:id', async (req, res) => {
  try {
    const groupings = await fileUtils.readFile(DATA_FILE);
    const groupingIndex = groupings.findIndex(group => group.groupingId === req.params.id);
    if (groupingIndex === -1) {
      return res.status(404).json({ error: 'Exhibit grouping not found' });
    }

    groupings.splice(groupingIndex, 1);
    await fileUtils.writeFile(DATA_FILE, groupings);
    res.status(204).send();
  } catch (error) {
    res.status(500).json({ error: 'Failed to delete exhibit grouping' });
  }
});

module.exports = router;