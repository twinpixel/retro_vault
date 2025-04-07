const express = require('express');
const router = express.Router();
const { v4: uuidv4 } = require('uuid');
const fileUtils = require('../utils/file-utils');

const DATA_FILE = 'objects.json';

// GET all objects
router.get('/', async (req, res) => {
  try {
    const objects = await fileUtils.readFile(DATA_FILE);
    res.json(objects);
  } catch (error) {
    res.status(500).json({ error: 'Failed to retrieve objects' });
  }
});

// GET a single object by ID
router.get('/:id', async (req, res) => {
  try {
    const objects = await fileUtils.readFile(DATA_FILE);
    const object = objects.find(obj => obj.uniqueId === req.params.id);
    if (!object) {
      return res.status(404).json({ error: 'Object not found' });
    }
    res.json(object);
  } catch (error) {
    res.status(500).json({ error: 'Failed to retrieve object' });
  }
});

// POST a new object
router.post('/', async (req, res) => {
  try {
    const objects = await fileUtils.readFile(DATA_FILE);

    //  Validate the request body  (basic validation)
    if (!req.body.nameTitle || !req.body.category || !req.body.subcategory) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    const newObject = {
      uniqueId: uuidv4(),  // Generate a unique ID
      ...req.body,
    };
    objects.push(newObject);
    await fileUtils.writeFile(DATA_FILE, objects);
    res.status(201).json(newObject);
  } catch (error) {
    res.status(500).json({ error: 'Failed to create object' });
  }
});

// PUT (update) an existing object
router.put('/:id', async (req, res) => {
  try {
    const objects = await fileUtils.readFile(DATA_FILE);
    const objectIndex = objects.findIndex(obj => obj.uniqueId === req.params.id);
    if (objectIndex === -1) {
      return res.status(404).json({ error: 'Object not found' });
    }

    //  Update the object (basic update)
    objects[objectIndex] = { ...objects[objectIndex], ...req.body };
    await fileUtils.writeFile(DATA_FILE, objects);
    res.json(objects[objectIndex]);
  } catch (error) {
    res.status(500).json({ error: 'Failed to update object' });
  }
});

// DELETE an object
router.delete('/:id', async (req, res) => {
  try {
    const objects = await fileUtils.readFile(DATA_FILE);
    const objectIndex = objects.findIndex(obj => obj.uniqueId === req.params.id);
    if (objectIndex === -1) {
      return res.status(404).json({ error: 'Object not found' });
    }
    objects.splice(objectIndex, 1);
    await fileUtils.writeFile(DATA_FILE, objects);
    res.status(204).send();  // 204 No Content
  } catch (error) {
    res.status(500).json({ error: 'Failed to delete object' });
  }
});

module.exports = router;