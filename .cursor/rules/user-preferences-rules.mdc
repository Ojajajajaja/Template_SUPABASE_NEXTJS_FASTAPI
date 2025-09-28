---
trigger: always_on
alwaysApply: true
---

# User Preferences Rules - STRICT ENFORCEMENT

## OAuth Button Design (ABSOLUTE PREFERENCE)

### MANDATORY OAuth Button Style
- **Style**: icon-only
- **Text**: FORBIDDEN
- **Design**: minimalist and elegant

### OAuth Button Implementation Rules
```typescript
// ✅ CORRECT: Icon-only OAuth button (USER PREFERENCE)
<Button variant="outline" size="icon" aria-label="Sign in with Google">
  <GoogleIcon />
</Button>

// ❌ FORBIDDEN: Text-based OAuth button (AGAINST USER PREFERENCE)
<Button>
  <GoogleIcon />
  Sign in with Google
</Button>
```

### OAuth Providers (ONLY THESE)
- Google (icon-only)
- GitHub (icon-only)

## UI Language Preference (ABSOLUTE)

### Interface Language Rules
- **ONLY English** for all UI text
- **ONLY English** for buttons and labels
- **ONLY English** for error messages
- **ONLY English** for tooltips
- **ONLY English** for help text

### Language Implementation Rules
```typescript
// ✅ CORRECT: English interface text
const messages = {
  auth: {
    signIn: "Sign In",
    email: "Email Address",
    password: "Password"
  }
};

// ❌ FORBIDDEN: French or other languages
const messages = {
  auth: {
    signIn: "Se connecter",  // FORBIDDEN
    email: "Adresse e-mail", // FORBIDDEN
    password: "Mot de passe" // FORBIDDEN
  }
};
```

## Design Style Preference (ENFORCED)

### Overall Design Philosophy
- **Style**: minimalist
- **Approach**: clean and elegant
- **Complexity**: simple and intuitive

### Design Implementation Rules

#### Component Design
- Clean, simple interfaces
- Minimal visual clutter
- Elegant spacing and typography
- Consistent design patterns

#### Color Scheme
- Support for dark/light modes
- High contrast for accessibility
- Consistent color palette
- Subtle, professional colors

#### Layout Principles
- Clean grid systems
- Appropriate white space
- Logical information hierarchy
- Mobile-first responsive design

## User Experience Preferences

### Navigation Style
- Simple, intuitive navigation
- Clear user flows
- Minimal clicks to complete tasks
- Consistent interaction patterns

### Form Design
- Clean, minimal form layouts
- Clear labels and instructions
- Appropriate field sizing
- Logical field grouping

### Feedback and Messaging
- Clear, concise error messages
- Positive confirmation messages
- Loading states and progress indicators
- Non-intrusive notifications

## Component Library Preferences

### UI Framework
- **Primary**: shadcn/ui
- **Style**: minimalist components
- **Customization**: subtle, elegant modifications

### Icon Usage
- **Style**: clean, simple icons
- **Size**: appropriate for context
- **Consistency**: same icon family throughout
- **OAuth**: icons without text labels

## Accessibility Preferences

### User Experience
- Keyboard navigation support
- Screen reader compatibility
- High contrast mode support
- Clear focus indicators

### Implementation Requirements
- ARIA labels for icon-only buttons
- Semantic HTML structure
- Logical tab order
- Alternative text for images

## Responsive Design Preferences

### Mobile-First Approach
- Clean mobile interfaces
- Touch-friendly interaction areas
- Simplified navigation on small screens
- Optimized content layout

### Desktop Experience
- Efficient use of screen space
- Professional, clean appearance
- Appropriate information density
- Elegant hover states and transitions

## Animation and Interaction Preferences

### Animation Style
- Subtle, purposeful animations
- Quick, responsive transitions
- No distracting or excessive motion
- Professional, polished feel

### Interaction Feedback
- Clear hover states
- Immediate response to user actions
- Smooth state transitions
- Consistent interaction patterns

## Content Presentation Preferences

### Typography
- Clean, readable fonts
- Appropriate font sizes and weights
- Good contrast ratios
- Consistent text styling

### Information Architecture
- Logical content organization
- Clear headings and sections
- Scannable content layout
- Appropriate content density

## Form and Input Preferences

### Input Design
- Clean, minimal input fields
- Clear labels and placeholders
- Appropriate field validation
- Elegant error state styling

### Button Design
- Consistent button styling
- Clear action hierarchy
- Appropriate sizing and spacing
- Icon-only OAuth buttons (PREFERENCE)

## Error Handling Preferences

### Error Message Style
- Clear, helpful error messages
- Non-threatening, supportive tone
- Actionable guidance when possible
- Consistent error presentation

### Error State Design
- Subtle, non-intrusive error indicators
- Clear recovery paths
- Maintain overall design consistency
- Professional error page designs

## Loading and Performance Preferences

### Loading States
- Clean, minimal loading indicators
- Appropriate loading animations
- Clear progress indication
- Maintain layout stability

### Performance Expectations
- Fast, responsive interactions
- Smooth scrolling and transitions
- Quick page load times
- Efficient resource usage

## Notification and Feedback Preferences

### Notification Style
- Subtle, non-intrusive notifications
- Clear, concise messaging
- Appropriate timing and placement
- Consistent notification design

### Success Feedback
- Positive, encouraging confirmation
- Clear completion indicators
- Appropriate celebration of achievements
- Professional success messaging

## Customization Preferences

### Theme Support
- Dark and light mode support
- Consistent theming across all components
- Smooth theme transitions
- User preference persistence

### Layout Flexibility
- Adaptable to different screen sizes
- Configurable layout options where appropriate
- Consistent behavior across devices
- Maintainable design system

## ENFORCEMENT RULES

### These preferences are MANDATORY
- Icon-only OAuth buttons (NO EXCEPTIONS)
- English-only interface (NO EXCEPTIONS)
- Minimalist design approach (NO EXCEPTIONS)
- Clean, professional appearance (NO EXCEPTIONS)

### Violation of these preferences is FORBIDDEN
- Text-based OAuth buttons
- Non-English UI text
- Cluttered or busy interfaces
- Inconsistent design patterns