const express = require('express');
const router = express.Router();
const { v4: uuidv4 } = require('uuid');
const fileUtils = require('../utils/file-utils');

const DATA_FILE = 'acquisitions.json';

// GET all acquisitions
router.get('/', async (req, res) => {
  try {
    const acquisitions = await fileUtils.readFile(DATA_FILE);
    res.json(acquisitions);
  } catch (error) {
    res.status(500).json({ error: 'Failed to retrieve acquisitions' });
  }
});

// GET a single acquisition by ID
router.get('/:id', async (req, res) => {
  try {
    const acquisitions = await fileUtils.readFile(DATA_FILE);
    const acquisition = acquisitions.find(acq => acq.acquisitionId === req.params.id);
    if (!acquisition) {
      return res.status(404).json({ error: 'Acquisition not found' });
    }
    res.json(acquisition);
  } catch (error) {
    res.status(500).json({ error: 'Failed to retrieve acquisition' });
  }
});

// POST a new acquisition
router.post('/', async (req, res) => {
  try {
    const acquisitions = await fileUtils.readFile(DATA_FILE);

    if (!req.body.acquisitionDate || !req.body.sourceOfAcquisition) {
      return res.status(400).json({ error: 'Missing required fields: acquisitionDate and sourceOfAcquisition' });
    }

    const newAcquisition = {
      acquisitionId: uuidv4(),
      acquisitionDate: req.body.acquisitionDate,
      sourceOfAcquisition: req.body.sourceOfAcquisition,
      lotDescription: req.body.lotDescription,
      acquisitionNotes: req.body.acquisitionNotes,
      conditionUponArrival: req.body.conditionUponArrival,
      appraisalInformation: req.body.appraisalInformation,
    };
    acquisitions.push(newAcquisition);
    await fileUtils.writeFile(DATA_FILE, acquisitions);
    res.status(201).json(newAcquisition);
  } catch (error) {
    res.status(500).json({ error: 'Failed to create acquisition' });
  }
});

// PUT (update) an existing acquisition
router.put('/:id', async (req, res) => {
  try {
    const acquisitions = await fileUtils.readFile(DATA_FILE);
    const acquisitionIndex = acquisitions.findIndex(acq => acq.acquisitionId === req.params.id);
    if (acquisitionIndex === -1) {
      return res.status(404).json({ error: 'Acquisition not found' });
    }

    acquisitions[acquisitionIndex] = { ...acquisitions[acquisitionIndex], ...req.body };
    await fileUtils.writeFile(DATA_FILE, acquisitions);
    res.json(acquisitions[acquisitionIndex]);
  } catch (error) {
    res.status(500).json({ error: 'Failed to update acquisition' });
  }
});

// DELETE an acquisition
router.delete('/:id', async (req, res) => {
  try {
    const acquisitions = await fileUtils.readFile(DATA_FILE);
    const acquisitionIndex = acquisitions.findIndex(acq => acq.acquisitionId === req.params.id);
    if (acquisitionIndex === -1) {
      return res.status(404).json({ error: 'Acquisition not found' });
    }

    acquisitions.splice(acquisitionIndex, 1);
    await fileUtils.writeFile(DATA_FILE, acquisitions);
    res.status(204).send();
  } catch (error) {
    res.status(500).json({ error: 'Failed to delete acquisition' });
  }
});

module.exports = router;