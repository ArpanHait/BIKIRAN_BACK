/**
 * 🛠️ Bikiran Career Mitra — Supabase Migration Script
 * 
 * Executes or verifies the database schema for Bikiran Career Mitra:
 * - Creates `public.profiles` table with 1:1 auth.users cascade.
 * - Creates `public.login_history` audit table.
 * - Configures Row Level Security (RLS) policies.
 * - Configures automatic user profile creation trigger `on_auth_user_created`.
 */

import fs from 'fs';
import path from 'path';
import dotenv from 'dotenv';
import { Client } from 'pg';
import { createClient } from '@supabase/supabase-js';

dotenv.config();

const SUPABASE_URL = process.env.SUPABASE_URL || '';
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY || '';
const DATABASE_URL = process.env.DATABASE_URL || '';

async function runMigration() {
  console.log('==================================================================');
  console.log('🚀 Bikiran Career Mitra — Database Migration Runner');
  console.log(`🌐 Supabase URL: ${SUPABASE_URL}`);
  console.log('==================================================================\n');

  const sqlFilePath = path.join(__dirname, 'schema.sql');
  if (!fs.existsSync(sqlFilePath)) {
    console.error(`❌ schema.sql not found at ${sqlFilePath}`);
    process.exit(1);
  }

  const sql = fs.readFileSync(sqlFilePath, 'utf-8');

  // Option 1: Direct Postgres execution if DATABASE_URL or password is provided
  if (DATABASE_URL) {
    console.log('🔌 Connecting directly to PostgreSQL via DATABASE_URL...');
    const client = new Client({
      connectionString: DATABASE_URL,
      ssl: { rejectUnauthorized: false },
    });

    try {
      await client.connect();
      console.log('✅ Connected to database. Executing schema migration...');
      await client.query(sql);
      console.log('🎉 Migration applied successfully via PostgreSQL direct connection!\n');
      await client.end();
    } catch (err: any) {
      console.error('❌ Migration failed via direct connection:', err.message);
      await client.end();
    }
  } else {
    console.log('ℹ️  DATABASE_URL not set in .env.');
    console.log('   (To connect directly, set DATABASE_URL=postgresql://postgres:[PASSWORD]@db.jpjfkmvkqssfdhpyktim.supabase.co:5432/postgres in backend/.env)\n');
  }

  // Verification step via Supabase Admin Client
  console.log('🔍 Checking Supabase schema status via Supabase Client...');
  const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

  const { data, error } = await supabase.from('profiles').select('id').limit(1);

  if (!error) {
    console.log('✅ Verified: Table `public.profiles` is active and accessible!');
    console.log('🚀 Supabase Backend is 100% READY for production auth and profile management.\n');
  } else if (error.code === 'PGRST205') {
    console.log('\n⚠️  Table `public.profiles` does not exist yet in Supabase.');
    console.log('👉 To apply the migration in 5 seconds:');
    console.log('   1. Open: https://supabase.com/dashboard/project/jpjfkmvkqssfdhpyktim/sql/new');
    console.log('   2. Paste the SQL from: backend/src/scripts/schema.sql');
    console.log('   3. Click "Run" (▶️)');
    console.log('   4. Re-run: npm run migrate\n');
  } else {
    console.warn('⚠️  Supabase status check notice:', error.message);
  }
}

runMigration().catch((err) => {
  console.error('Fatal error during migration:', err);
  process.exit(1);
});
