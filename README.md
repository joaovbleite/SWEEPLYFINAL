# SWEEPLYPRO

## About Sweeply

Sweeply is a comprehensive business management application designed specifically for cleaning service professionals. The app streamlines daily operations, client management, scheduling, and financial tracking to help cleaning businesses grow and operate more efficiently.

### Key Features

- **Smart Scheduling**: Interactive calendar with day, list, and map views for optimal route planning
- **Client Management**: Easily track client information, service history, and preferences
- **Task Management**: Create, assign, and track tasks with priority levels and completion status
- **Business Health Dashboard**: Visual analytics to monitor business performance and growth
- **Financial Tools**: Invoice generation, expense tracking, and payment processing
- **Team Coordination**: Assign tasks to team members and track progress

### Technical Details

- Built with SwiftUI for iOS
- Uses SwiftData for local data persistence
- Implements responsive design for various iOS devices
- Features custom UI components with brand-specific styling

## Getting Started

1. Clone the repository
2. Open the project in Xcode
3. Build and run on your iOS device or simulator

## GitHub Integration

This repository is set up with automatic GitHub integration. To push your changes to GitHub, you can use the provided script:

```bash
./git-push-all.sh "Your commit message here"
```

This script will:
1. Add all changed files
2. Commit the changes with your provided message
3. Push the changes to GitHub

## Alias Setup

For convenience, an alias has been added to your .zshrc file. After restarting your terminal or running `source ~/.zshrc`, you can use:

```bash
gpa "Your commit message here"
```

This alias will perform the same actions as the script.

