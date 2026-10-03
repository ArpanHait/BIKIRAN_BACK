# 🚀 Bikiran Career Mitra — Backend Server & Supabase Keep-Alive

This is the standalone production backend server for **Bikiran Career Mitra**, designed for free-tier hosting on **Render** paired with **UptimeRobot** to keep both **Render and your Supabase PostgreSQL database 100% active and awake 24/7**.

---

## 🌟 Why This Architecture Never Sleeps or Pauses:
* **Render Free Tier**: Automatically sleeps after 15 minutes of inactivity.
* **Supabase Free Tier**: Automatically pauses databases after 7 days of inactivity.
* **The Bikiran Keep-Alive Engine**:
  - UptimeRobot pings `https://bikiran.onrender.com/health` every 5–10 minutes.
  - Render responds with HTTP 200, resetting its 15-minute sleep timer (**Render stays awake 24/7**).
  - During every health check, Render executes a lightweight query against `public.profiles` on Supabase (**Supabase registers active traffic and NEVER pauses**).

---

## 🌐 Deploying to Render (Step-by-Step):

1. Go to [Render Dashboard](https://dashboard.render.com/) and click **New +** ➔ **Web Service**.
2. Connect your Git repository (`BIKIRAN_DEV`).
3. Fill in the service configuration:
   - **Name**: `bikiran` (Live URL: `https://bikiran.onrender.com`)
   - **Region**: Singapore or closest to India
   - **Root Directory**: `backend`
   - **Runtime**: `Node`
   - **Build Command**: `npm install && npm run build`
   - **Start Command**: `npm start`
   - **Instance Type**: `Free`
4. Add **Environment Variables** (under *Environment* tab):
   - `PORT`: `5000`
   - `NODE_ENV`: `production`
   - `SUPABASE_URL`: `https://jpjfkmvkqssfdhpyktim.supabase.co`
   - `SUPABASE_SERVICE_ROLE_KEY`: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpwamZrbXZrcXNzZmRocHlrdGltIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc5MDgzMDA0OSwiZXhwIjoyMTA2NDA2MDQ5fQ.T0NdckV3T_LGRSBAmP4TV6PfJ3tb3DZQ53TZR_rxsPA`
5. Click **Deploy Web Service**.

---

## ⏱️ UptimeRobot Configuration (Keeps Render & Supabase Alive 24/7):

1. Go to [UptimeRobot](https://uptimerobot.com/) (Free Account).
2. Click **+ Add New Monitor**:
   - **Monitor Type**: `HTTP(s)`
   - **Friendly Name**: `Bikiran Backend & Supabase Keep-Alive`
   - **URL (or IP)**: `https://bikiran.onrender.com/health`
   - **Monitoring Interval**: `5 minutes` (or `10 minutes`)
3. Click **Create Monitor**.

---

## 🔍 Local Verification:
```bash
cd backend
npm run build
npm start
# In browser or curl: http://localhost:5000/health
```
Sample response:
```json
{
  "status": "ok",
  "uptimeSeconds": 4,
  "server": "healthy",
  "database": {
    "provider": "Supabase PostgreSQL",
    "status": "connected",
    "latencyMs": 140,
    "notice": null
  },
  "message": "Bikiran Career Mitra Backend & Supabase Database Kept Alive 🚀",
  "timestamp": "2026-09-26T08:20:00.000Z"
}
```
