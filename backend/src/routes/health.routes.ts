/**
 * 🏥 Health Check Route for UptimeRobot, Render & Supabase Keep-Alive
 * Directory: backend/src/routes/health.routes.ts
 * 
 * ℹ️ WHAT DOES THIS ROUTE DO?
 * - Keeps Render Awake: Prevents free-tier web services from sleeping after 15 min.
 * - Keeps Supabase Alive: Executes a lightweight query against public.profiles so
 *   Supabase's free tier inactivity timer (7 days) NEVER triggers.
 */

import { Router, Request, Response } from 'express';
import { supabase } from '../services/supabase';

const router = Router();

router.get('/', async (_req: Request, res: Response) => {
  const startTime = Date.now();
  let dbStatus = 'connected';
  let dbLatencyMs = 0;
  let dbNotice: string | null = null;

  try {
    // 🏓 Ping Supabase database with a lightweight limit(1) query to register database activity
    const { error } = await supabase.from('profiles').select('id').limit(1);
    dbLatencyMs = Date.now() - startTime;

    if (error) {
      dbStatus = 'notice';
      dbNotice = error.message;
    }
  } catch (err: any) {
    dbStatus = 'unreachable';
    dbNotice = err.message || 'Unknown database ping error';
  }

  res.status(200).json({
    status: 'ok',
    uptimeSeconds: Math.round(process.uptime()),
    server: 'healthy',
    database: {
      provider: 'Supabase PostgreSQL',
      status: dbStatus,
      latencyMs: dbLatencyMs,
      notice: dbNotice,
    },
    message: 'Bikiran Career Mitra Backend & Supabase Database Kept Alive 🚀',
    timestamp: new Date().toISOString(),
  });
});

export default router;
