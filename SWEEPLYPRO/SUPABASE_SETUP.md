# Supabase Authentication Setup

## Overview
This app uses Supabase for user authentication and account management only. All business data (tasks, clients, invoices, jobs) remains in SwiftData for optimal performance and offline capability.

## Architecture
- **Supabase**: User authentication, user profiles, subscription management
- **SwiftData**: All business data (tasks, clients, invoices, jobs, schedules)

## Features Implemented

### Authentication
- ✅ User sign up with email/password
- ✅ User sign in
- ✅ Password reset via email
- ✅ User profile management
- ✅ Sign out functionality
- ✅ Automatic session management

### Database Schema
- ✅ `user_profiles` table with Row Level Security
- ✅ Automatic profile creation on user signup
- ✅ User profile updates

### Integration
- ✅ Authentication flow in main app
- ✅ User profile section in MoreView
- ✅ Profile editing with business information
- ✅ Subscription tier display

## Configuration
- **Supabase URL**: https://nzidlxeqrcxfrdesyiyb.supabase.co
- **Database**: PostgreSQL with Row Level Security enabled
- **Authentication**: Email/password with email confirmations

## Files Added/Modified
- `SupabaseAuthManager.swift` - Authentication manager
- `AuthenticationView.swift` - Sign in/up views
- `SWEEPLYPROApp.swift` - Authentication integration
- `MoreView.swift` - User profile section
- `supabase/migrations/` - Database schema

## Usage
1. Users sign up/sign in through the authentication flow
2. User profiles are stored in Supabase
3. All business data remains in SwiftData
4. Users can manage their profile in the More tab
5. Sign out clears authentication but preserves local SwiftData

## Benefits
- **User Management**: Centralized authentication and user accounts
- **Performance**: Business data stays local with SwiftData
- **Offline Capability**: App works offline for business operations
- **Scalability**: User accounts can be managed across devices
- **Security**: Row Level Security ensures data privacy 