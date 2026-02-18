# 🚀 Deployment Guide

Complete step-by-step guide to deploy your Blood Donation System as a live demo.

## Prerequisites

- [x] GitHub account
- [x] Vercel account (free tier) - [Sign up here](https://vercel.com/signup)
- [x] Supabase project with database set up
- [x] Git installed locally

---

## Step 1: Prepare Your Repository

### 1.1 Commit Your Code

```bash
# Add all files
git add .

# Create initial commit
git commit -m "Initial commit: Blood Donation Management System

Features:
- User authentication (login, register, password reset)
- Donation application system with health questionnaire
- Secretary review dashboard
- Admin management panel
- Appointment scheduling
- Profile management

Tech: Nuxt 3, Vue 3, TypeScript, Supabase, Tailwind CSS"

# Check status
git status
```

### 1.2 Create GitHub Repository

1. Go to [github.com/new](https://github.com/new)
2. Repository name: `blood-donation-system`
3. Description: "Full-stack blood donation management platform built with Nuxt 3 and Supabase"
4. Choose **Public** (for portfolio visibility)
5. **Don't** initialize with README (you already have one)
6. Click "Create repository"

### 1.3 Push to GitHub

```bash
# Add remote (replace YOUR_USERNAME)
git remote add origin https://github.com/YOUR_USERNAME/blood-donation-system.git

# Push code
git branch -M main
git push -u origin main
```

---

## Step 2: Deploy to Vercel

### 2.1 Import Project

1. Go to [vercel.com](https://vercel.com) and sign in
2. Click **"Add New"** → **"Project"**
3. Import your GitHub repository: `blood-donation-system`
4. Vercel will auto-detect Nuxt 3 settings ✅

### 2.2 Configure Environment Variables

In the Vercel project configuration, add these environment variables:

| Name | Value |
|------|-------|
| `SUPABASE_URL` | Your Supabase project URL |
| `SUPABASE_KEY` | Your Supabase anon/public key |

**Where to find these:**
- Go to your Supabase project
- Settings → API
- Copy "Project URL" and "anon public" key

### 2.3 Deploy

1. Click **"Deploy"**
2. Wait 2-3 minutes for build to complete
3. Your app will be live at: `https://your-project-name.vercel.app`

---

## Step 3: Configure Supabase for Production

### 3.1 Update Redirect URLs

1. Go to Supabase Dashboard → Authentication → URL Configuration
2. Add your Vercel domain to:
   - **Site URL**: `https://your-project-name.vercel.app`
   - **Redirect URLs**:
     - `https://your-project-name.vercel.app/reset-password`
     - `https://your-project-name.vercel.app/**` (wildcard)

### 3.2 Email Templates (Optional)

Update email templates in Supabase:
- Authentication → Email Templates
- Customize password reset email with your domain

---

## Step 4: Test Your Live App

### 4.1 Smoke Test Checklist

- [ ] Landing page loads
- [ ] Registration works
- [ ] Login works
- [ ] Password reset email sends
- [ ] User can view dashboard
- [ ] Application submission works
- [ ] Secretary can review applications
- [ ] Admin can create appointments

### 4.2 Create Demo Accounts

Create test accounts for recruiters to try:

**Citizen Account:**
- Email: `demo.citizen@example.com`
- Password: `Demo123!`

**Secretary Account:**
- Email: `demo.secretary@example.com`
- Password: `Demo123!`

**Admin Account:**
- Email: `demo.admin@example.com`
- Password: `Demo123!`

---

## Step 5: Add Live Demo to README

Update your README.md:

```markdown
[![Live Demo](https://img.shields.io/badge/demo-live-brightgreen)](https://your-project-name.vercel.app)

## 🌐 Live Demo

Try it out: **[https://your-project-name.vercel.app](https://your-project-name.vercel.app)**

### Demo Credentials

**Citizen/Donor:**
- Email: demo.citizen@example.com
- Password: Demo123!

**Secretary:**
- Email: demo.secretary@example.com
- Password: Demo123!

**Admin:**
- Email: demo.admin@example.com
- Password: Demo123!
```

Push the update:
```bash
git add README.md
git commit -m "docs: Add live demo link and credentials"
git push
```

---

## Step 6: Portfolio Presentation

### 6.1 Update Your Portfolio

Add this project with:
- **Title**: Blood Donation Management System
- **Description**: Full-stack blood donation platform with role-based access control
- **Live Demo**: Link to Vercel deployment
- **Source Code**: Link to GitHub repo
- **Tech Stack**: Nuxt 3, Vue 3, TypeScript, Supabase, Tailwind CSS
- **Screenshot**: Take a screenshot of your dashboard

### 6.2 GitHub Repository Polish

Make your repo stand out:

1. **Add Topics** (on GitHub repo page):
   - `nuxt3`, `vue3`, `typescript`, `supabase`, `tailwindcss`
   - `blood-donation`, `healthcare`, `full-stack`

2. **Add Repository Description**:
   > Full-stack blood donation management platform with role-based access, application review system, and appointment scheduling

3. **Pin to Profile**:
   - Go to your GitHub profile
   - Pin this repository (shows up prominently)

---

## 🎉 You're Live!

Your portfolio project is now:
- ✅ Deployed and accessible worldwide
- ✅ Automatically rebuilds on every push to `main`
- ✅ Has a professional README
- ✅ Ready for job applications

---

## 🔄 Future Updates

To deploy updates:

```bash
# Make your changes
git add .
git commit -m "feat: Add new feature"
git push

# Vercel automatically rebuilds! 🚀
```

---

## 📊 Monitoring (Optional)

**Vercel Analytics** (Free):
- Vercel Dashboard → Your Project → Analytics
- See page views, performance, and visitors

**Supabase Dashboard**:
- Monitor API usage
- Check database queries
- View authentication metrics

---

## 🆘 Troubleshooting

### Build Fails on Vercel
- Check build logs in Vercel dashboard
- Ensure `package.json` has correct scripts
- Verify Node version compatibility

### 404 Errors
- Check Nuxt routing
- Ensure pages are in `/pages` directory

### Authentication Not Working
- Verify environment variables in Vercel
- Check Supabase redirect URLs include Vercel domain

### Can't Connect to Database
- Verify `SUPABASE_URL` and `SUPABASE_KEY` in Vercel
- Check Supabase project is active

---

## 💡 Pro Tips

1. **Custom Domain** (Optional):
   - Buy domain on Namecheap/GoDaddy
   - Add to Vercel: Settings → Domains
   - Example: `blooddonation.yourname.com`

2. **Environment Branches**:
   - Create `dev` branch for testing
   - Vercel creates preview URLs for each branch

3. **Performance**:
   - Vercel Edge Network = Fast globally
   - Supabase uses PostgreSQL with global CDN

---

**Questions?** Check [Vercel Docs](https://vercel.com/docs) or [Nuxt Docs](https://nuxt.com/docs)
