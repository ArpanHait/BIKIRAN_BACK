/**
 * 🚀 Bikiran Career Mitra — Backend Express Server
 * Designed for deployment on Render.
 */

import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import healthRoutes from './routes/health.routes';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 5000;

app.use(cors());
app.use(express.json());

// Routes
app.use('/health', healthRoutes);

app.get('/', (_req, res) => {
  res.send('Bikiran Career Mitra Backend API');
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
