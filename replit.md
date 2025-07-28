# Vehicle Gallery - Flutter Android App

## Overview

This is a Flutter Android application for viewing vehicle images and videos with an iOS-like interface. The app provides comprehensive vehicle management features including CRUD operations, advanced media gallery, search and filtering, and offline SQLite storage. Built with modern Flutter architecture and designed for professional vehicle management with beautiful media galleries.

## User Preferences

Preferred communication style: Simple, everyday language.

## Recent Changes (January 2025)

### Complete Flutter Project Setup
✓ Created Flutter app with iOS-like Cupertino design theme
✓ Implemented SQLite database with sample vehicle data  
✓ Built responsive vehicle grid with masonry layout
✓ Added full-screen media gallery with zoom and video playback
✓ Created comprehensive CRUD screens (Home, Detail, Add, Edit)
✓ Integrated advanced search and filtering functionality
✓ Configured GitHub Actions for automated APK building
✓ Set up Android permissions and manifest configuration

### GitHub Actions Build Fix (July 28, 2025)
✓ Fixed APK build error by removing deprecated `useProguard()` method
✓ Updated android/app/build.gradle to remove unsupported Gradle configuration
✓ Resolved 7 Flutter analyze issues (unnecessary imports, deprecated APIs, null assertions)
✓ Fixed VideoPlayerController deprecated method by using networkUrl()
✓ Created test directory and basic widget test to resolve test errors
✓ Added shrinkResources false to prevent resource shrinking conflicts
✓ Created assets/images directory to resolve asset path errors
✓ RESOLVED NoClassDefFoundError with legacy compatibility stack
✓ **FINAL STABLE BUILD Configuration:**
  - Android Gradle Plugin: 7.1.3 (OutputFile class compatible)
  - Gradle Wrapper: 7.3.3 (proven stable with AGP 7.1.3)
  - Java Version: 11 (GitHub Actions) + JVM Target 1.8 (builds)
  - SDK Versions: compileSdk/targetSdk = 33 (proven stable)
  - HYBRID APPROACH: Java 11 runner + Java 8 compatibility builds
✓ Resolved NoClassDefFoundError by reverting to legacy AGP stack
✓ Removed project.evaluationDependsOn(':app') causing build conflicts
✓ ProGuard rules protecting Android Build and Flutter framework classes  
✓ Complete documentation in GRADLE_FIX.md with troubleshooting steps root cause analysis

## Flutter App Architecture

### Mobile Application Framework
- **Platform**: Android (with iOS-like interface design)
- **Framework**: Flutter 3.16+ with Dart programming language
- **UI Design**: Cupertino (iOS-style) components with Material Design 3
- **State Management**: StatefulWidget with setState pattern
- **Navigation**: Standard Flutter navigation with CupertinoPageRoute

### Database & Storage
- **Local Database**: SQLite with sqflite package for offline storage
- **Media Storage**: Device file system with proper Android permissions
- **Data Models**: Dart classes with JSON serialization
- **Sample Data**: Pre-loaded vehicle database with demo content

### Key Flutter Components
- **Vehicle Grid**: Masonry layout using flutter_staggered_grid_view
- **Media Gallery**: Full-screen viewer with photo_view and video_player
- **Search & Filter**: Real-time filtering with custom widgets
- **Form Handling**: Flutter form validation with custom text fields
- **Theme System**: Custom iOS-like theme with light/dark mode support

### External Dependencies
- **Media Handling**: image_picker, file_picker for camera/gallery access
- **Network Images**: cached_network_image for efficient image loading
- **Database**: sqflite for SQLite operations
- **Sharing**: share_plus for media sharing capabilities
- **UI Components**: Custom Cupertino-styled widgets

## System Architecture

### Frontend Architecture
- **Framework**: React 18 with TypeScript
- **Build Tool**: Vite for fast development and optimized builds
- **UI Library**: shadcn/ui components built on Radix UI primitives
- **Styling**: Tailwind CSS with custom CSS variables for theming
- **State Management**: TanStack Query (React Query) for server state management
- **Routing**: Wouter for lightweight client-side routing
- **Forms**: React Hook Form with Zod validation

### Backend Architecture
- **Runtime**: Node.js with Express.js
- **Language**: TypeScript with ES modules
- **Database ORM**: Drizzle ORM for type-safe database operations
- **File Uploads**: Multer middleware for handling media file uploads
- **Development**: Hot reload with Vite middleware integration

### Data Storage Solutions
- **Primary Database**: PostgreSQL (configured for use with Neon Database)
- **File Storage**: Local filesystem storage for uploaded media files
- **Session Storage**: In-memory storage with fallback for development
- **Schema**: Single vehicles table with array support for media files

## Key Components

### Database Schema
- **Vehicles Table**: Stores vehicle information including make, model, year, license plate, VIN, mileage, price, status, and media files
- **Media Files**: Stored as array of file paths in the database
- **Timestamps**: Automatic created_at and updated_at tracking

### API Endpoints
- `GET /api/vehicles` - List vehicles with search and filter support
- `POST /api/vehicles` - Create new vehicle with media upload
- `PUT /api/vehicles/:id` - Update existing vehicle
- `DELETE /api/vehicles/:id` - Delete vehicle
- `POST /api/vehicles/:id/media` - Upload additional media files

### Frontend Components
- **Vehicle Card**: Displays vehicle information with media preview
- **Vehicle Form Modal**: Create/edit vehicle form with drag-and-drop media upload
- **Media Viewer Modal**: Full-screen media viewer with zoom and navigation
- **Search Filter Bar**: Real-time search and filtering by make/year
- **Header**: Navigation and branding component

### File Upload System
- **Supported Formats**: JPEG, PNG, GIF images; MP4, WebM videos
- **File Size Limit**: 10MB per file
- **Storage Location**: `server/uploads/` directory
- **File Naming**: Timestamp-based unique naming to prevent conflicts

## Data Flow

### Vehicle Management Flow
1. User creates/edits vehicle through form modal
2. Form data and files are validated client-side using Zod schema
3. Files are uploaded via multipart/form-data to Express server
4. Server validates files and stores them in uploads directory
5. Vehicle data is saved to PostgreSQL database via Drizzle ORM
6. Client-side cache is invalidated and updated via React Query

### Search and Filter Flow
1. User enters search terms or selects filters
2. Query parameters are constructed and sent to backend
3. Database query is executed with appropriate WHERE clauses
4. Results are returned and cached by React Query
5. UI updates automatically with filtered results

### Media Viewing Flow
1. User clicks on media thumbnail in vehicle card
2. Media viewer modal opens with full-screen display
3. Support for zoom, navigation, and download functionality
4. Media files are served statically from uploads directory

## External Dependencies

### Frontend Dependencies
- **UI Components**: Extensive Radix UI component library
- **Styling**: Tailwind CSS with PostCSS processing
- **Form Handling**: React Hook Form with Zod resolver
- **Date Handling**: date-fns for date manipulation
- **Icons**: Lucide React for consistent iconography
- **Carousel**: Embla Carousel for media navigation

### Backend Dependencies
- **Database**: Neon Database serverless PostgreSQL
- **ORM**: Drizzle ORM with Drizzle Kit for migrations
- **File Upload**: Multer for multipart form handling
- **Session Storage**: connect-pg-simple for PostgreSQL session store
- **Validation**: Zod for runtime type validation

### Development Dependencies
- **Build Tools**: Vite with React plugin and TypeScript support
- **Development**: tsx for TypeScript execution
- **Replit Integration**: Custom plugins for Replit environment

## Deployment Strategy

### Build Process
1. Frontend built with Vite to `dist/public/` directory
2. Backend bundled with esbuild to `dist/index.js`
3. Static assets and uploads served by Express in production

### Environment Configuration
- **Development**: Vite dev server with Express API integration
- **Production**: Single Express server serving both API and static files
- **Database**: PostgreSQL connection via DATABASE_URL environment variable

### File Structure
- `/client` - React frontend application
- `/server` - Express backend application  
- `/shared` - Shared TypeScript schemas and types
- `/migrations` - Drizzle database migration files
- `/server/uploads` - Media file storage directory

The system is designed for easy deployment on platforms like Replit, with automatic database provisioning and file storage handling built into the architecture.