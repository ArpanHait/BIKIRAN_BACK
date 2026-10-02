/**
 * 📲 Bikiran Career Mitra — Deep Link Web Bridge
 * Directory: backend/src/routes/openApp.routes.ts
 * 
 * ℹ️ WHAT IS THIS FILE FOR?
 * Email clients like Gmail, Outlook, and Yahoo strictly block custom URI schemes
 * like 'bikiran://welcome' because they only allow 'http://' and 'https://' links.
 * 
 * When a user taps "Open Bikiran App" in an email, it opens this HTTPS URL:
 * https://bikiran.onrender.com/open-app?action=<ACTION>&email=<EMAIL>
 * 
 * Supported Actions:
 * 1. 'signup-otp': Routes directly to Registration Step 2 (OTP Entry) with email pre-filled.
 * 2. 'change-email-otp': Routes to Profile / Email Verification modal.
 * 3. 'reset-password': Routes to Login with ForgotPasswordModal open at Step 2 (OTP Entry).
 * 4. 'reauth': Routes to Login with email pre-filled and password focused.
 * 
 * This page immediately triggers the native deep link on Android & iOS:
 * - Android: intent://${appPath}#Intent;scheme=bikiran;package=com.bikiran.careerguidance;end
 * - iOS / Fallback: bikiran://${appPath}
 */

import { Router, Request, Response } from 'express';

const router = Router();

router.get('/', (req: Request, res: Response) => {
  const action = (req.query.action as string) || '';
  const email = (req.query.email as string) || '';

  // Determine directional target path inside the Expo Router app
  let appPath = 'welcome';
  let statusMessage = 'Opening the app on your device...';

  if (action === 'signup-otp') {
    const emailParam = email ? `&email=${encodeURIComponent(email)}` : '';
    appPath = `register?step=2${emailParam}`;
    statusMessage = 'Returning to your verification code screen...';
  } else if (action === 'change-email-otp') {
    const emailParam = email ? `&email=${encodeURIComponent(email)}` : '';
    appPath = `(tabs)?modal=profile&action=verify-email${emailParam}`;
    statusMessage = 'Opening your email confirmation screen...';
  } else if (action === 'reset-password') {
    const emailParam = email ? `&email=${encodeURIComponent(email)}` : '';
    appPath = `login?modal=forgot-password&step=otp${emailParam}`;
    statusMessage = 'Opening your password reset screen...';
  } else if (action === 'reauth') {
    const emailParam = email ? `&email=${encodeURIComponent(email)}` : '';
    appPath = `login?reauth=true${emailParam}`;
    statusMessage = 'Opening login screen...';
  }

  // Construct native Android Intent and iOS custom scheme URIs
  const androidIntentUrl = `intent://${appPath}#Intent;scheme=bikiran;package=com.bikiran.careerguidance;end`;
  const iosSchemeUrl = `bikiran://${appPath}`;

  const html = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Opening Bikiran Career Mitra...</title>
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
      background-color: #FDF1DB;
      color: #0F172A;
      display: flex;
      align-items: center;
      justify-content: center;
      min-height: 100vh;
      padding: 24px;
    }
    .card {
      background: #FEF9F3;
      border: 1px solid #EFE4D2;
      border-radius: 20px;
      padding: 36px 28px;
      max-width: 440px;
      width: 100%;
      text-align: center;
      box-shadow: 0 10px 25px rgba(0, 0, 0, 0.05);
    }
    .logo-badge {
      width: 64px;
      height: 64px;
      background-color: #FFF3E6;
      border: 2px solid #FF6B00;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      margin: 0 auto 20px;
      font-size: 28px;
    }
    h1 {
      font-size: 22px;
      color: #046BD2;
      margin-bottom: 8px;
      font-weight: 700;
    }
    p {
      color: #475569;
      font-size: 15px;
      line-height: 1.5;
      margin-bottom: 24px;
    }
    .open-btn {
      display: inline-block;
      background-color: #FF6B00;
      color: #FFFFFF;
      font-size: 16px;
      font-weight: 600;
      text-decoration: none;
      padding: 14px 32px;
      border-radius: 28px;
      box-shadow: 0 4px 12px rgba(255, 107, 0, 0.3);
      cursor: pointer;
      border: none;
      transition: transform 0.2s, background-color 0.2s;
    }
    .open-btn:active {
      transform: scale(0.98);
      background-color: #E56000;
    }
    .footnote {
      margin-top: 24px;
      font-size: 13px;
      color: #94A3B8;
    }
  </style>
  <script>
    var androidIntent = ${JSON.stringify(androidIntentUrl)};
    var iosScheme = ${JSON.stringify(iosSchemeUrl)};

    function triggerAppOpen() {
      var isAndroid = /Android/i.test(navigator.userAgent);
      if (isAndroid) {
        window.location.href = androidIntent;
      } else {
        window.location.href = iosScheme;
      }
    }

    // Auto-launch app immediately upon page load
    window.addEventListener('DOMContentLoaded', function() {
      triggerAppOpen();
    });
  </script>
</head>
<body>
  <div class="card">
    <div class="logo-badge">🚀</div>
    <h1>Bikiran Career Mitra</h1>
    <p>${statusMessage}</p>
    
    <button class="open-btn" onclick="triggerAppOpen()">Open Bikiran App →</button>
    
    <p class="footnote">
      If the app didn't open automatically, tap the button above.
    </p>
  </div>
</body>
</html>`;

  res.setHeader('Content-Type', 'text/html');
  res.send(html);
});

export default router;
