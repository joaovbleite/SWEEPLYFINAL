# Sweeply Pro Widgets

This extension provides widgets for the Sweeply Pro app, displaying key business metrics directly on the user's home screen.

## Widget Features

- **Small Widget**: Alternates between showing today's customer count and due tasks
- **Medium Widget**: Shows both customer count and due tasks side by side
- **Large Widget**: Comprehensive dashboard with customers, tasks, and business health metrics

## Configuration Options

Users can customize their widget with:
- **Display Mode**: Choose to show customers only, tasks only, or alternate between both
- **Color Theme**: Select from blue, green, or teal themes

## Developer Setup

### Running the Widget in Xcode

To properly run and debug the widget in Xcode:

1. Select the WIDGETS scheme in Xcode
2. Edit the scheme (Product → Scheme → Edit Scheme...)
3. Select "Run" from the left sidebar
4. Go to the "Arguments" tab
5. Under "Environment Variables", add:
   - Name: `_XCWidgetKind`
   - Value: `sweeply.SWEEPLYPRO.WIDGETS`
6. Click "Close" to save

### Widget Structure

- **SweeplyWidgetProvider.swift**: Data provider for the widget
- **SweeplyWidgetViews.swift**: UI components for different widget sizes
- **SharedModels.swift**: Data models for widget use
- **WIDGETS.swift**: Main widget configuration
- **AppIntent.swift**: Configuration options for the widget

## Implementation Notes

- The widget currently uses simulated data
- In production, implement proper data sharing between the main app and widget using App Groups
- Update the WidgetDataManager class to fetch real data from the shared container 