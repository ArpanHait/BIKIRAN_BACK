import express, { Request, Response } from 'express';
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

app.get('/', (_req: Request, res: Response) => {
  res.send('Bikiran Career Mitra Backend API');
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
