// routes/cows.js
const express = require('express');
const router = express.Router();
const pool = require('../db');

// Endpoint untuk menambah data pada tabel feed_hijauan
router.post('/feed_hijauan', async (req, res) => {
    const { cow_id, date, amount } = req.body;
    try {
        const result = await pool.query(
            'INSERT INTO feed_hijauan (cow_id, date, amount) VALUES ($1, $2, $3) RETURNING *',
            [cow_id, date, amount]
        );
        res.status(201).json(result.rows[0]);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Endpoint untuk menambah data pada tabel feed_sentrate
router.post('/feed_sentrate', async (req, res) => {
    const { cow_id, date, amount } = req.body;
    try {
        const result = await pool.query(
            'INSERT INTO feed_sentrate (cow_id, date, amount) VALUES ($1, $2, $3) RETURNING *',
            [cow_id, date, amount]
        );
        res.status(201).json(result.rows[0]);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Endpoint untuk menambah data pada tabel milk_production
router.post('/milk_production', async (req, res) => {
    const { cow_id, date, production_amount } = req.body;
    try {
        const result = await pool.query(
            'INSERT INTO milk_production (cow_id, date, production_amount) VALUES ($1, $2, $3) RETURNING *',
            [cow_id, date, production_amount]
        );
        res.status(201).json(result.rows[0]);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Endpoint untuk menambah data pada tabel body_weight
router.post('/body_weight', async (req, res) => {
    const { cow_id, date, weight } = req.body;
    try {
        const result = await pool.query(
            'INSERT INTO body_weight (cow_id, date, weight) VALUES ($1, $2, $3) RETURNING *',
            [cow_id, date, weight]
        );
        res.status(201).json(result.rows[0]);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Endpoint untuk memperbarui data pada tabel cows
router.put('/cows/:cow_id', async (req, res) => {
    const { cow_id } = req.params;
    const { age, health_record, stress_level, gender, birahi, status, note } = req.body;

    try {
        const result = await pool.query(
            'UPDATE cows SET age = $1, health_record = $2, stress_level = $3, gender = $4, birahi = $5, status = $6, note = $7 WHERE cow_id = $8 RETURNING *',
            [age, health_record, stress_level, gender, birahi, status, note, cow_id]
        );
        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Cow not found' });
        }
        res.json(result.rows[0]);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;
