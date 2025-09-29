# Frontend Template avec Shadcn/UI

## 🎨 Interface Moderne avec Shadcn/UI

Le frontend a été complètement refactorisé avec **Shadcn/UI** pour offrir une expérience utilisateur moderne et professionnelle.

### ✨ Nouvelles Fonctionnalités

#### **Landing Page Redesignée**
- Design moderne avec gradients et animations
- Logo placeholder configurable (⚡)
- Section hero avec call-to-action
- Cards de fonctionnalités avec effets hover
- Tech stack display
- Responsive design complet

#### **Authentification Repensée**
- Interface à deux colonnes (hero + formulaire)
- Design card moderne avec Shadcn/UI
- Validation en temps réel
- États de chargement élégants
- Messages d'erreur intégrés
- Mode sombre/clair automatique

#### **Dashboard Professionnel**
- Header avec navigation et profil
- Cards de statistiques (exemples)
- Section de bienvenue interactive
- Profil utilisateur intégré
- Design cohérent et extensible

### 🎨 Système de Thèmes

#### **Support Automatique des Thèmes**
```tsx
// Le ThemeProvider est configuré dans layout.tsx
<ThemeProvider
  attribute="class"
  defaultTheme="system"
  enableSystem
  disableTransitionOnChange
>
```

#### **Toggle de Thème**
Composant `ModeToggle` disponible partout :
- Thème clair
- Thème sombre  
- Automatique (système)

### 🧩 Composants Shadcn/UI Installés

Les composants suivants sont disponibles :

- `Button` - Boutons avec variantes
- `Card` - Container avec header/content
- `Input` - Champs de saisie
- `Label` - Labels pour formulaires
- `Form` - Gestion de formulaires
- `DropdownMenu` - Menus déroulants

### 🎯 Structure des Couleurs

Le système utilise les variables CSS de Shadcn/UI :

```css
:root {
  --background: oklch(1 0 0);
  --foreground: oklch(0.145 0 0);
  --primary: oklch(0.205 0 0);
  --secondary: oklch(0.97 0 0);
  --muted: oklch(0.97 0 0);
  --accent: oklch(0.97 0 0);
  --destructive: oklch(0.577 0.245 27.325);
  --border: oklch(0.922 0 0);
  --input: oklch(0.922 0 0);
  --ring: oklch(0.708 0 0);
}
```

### 🚀 Utilisation

#### **Ajouter de Nouveaux Composants**
```bash
npx shadcn@latest add [component-name]
```

#### **Utiliser les Composants**
```tsx
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"

export function MyComponent() {
  return (
    <Card>
      <CardHeader>
        <CardTitle>Mon Titre</CardTitle>
      </CardHeader>
      <CardContent>
        <Button>Action</Button>
      </CardContent>
    </Card>
  )
}
```

### 🛠 Personnalisation

#### **Modifier les Couleurs**
Éditez `src/app/globals.css` pour changer :
- Couleurs du thème clair (`:root`)
- Couleurs du thème sombre (`.dark`)
- Radius des bordures (`--radius`)

#### **Ajouter des Variantes**
Utilisez la fonction `cn()` pour combiner les classes :
```tsx
import { cn } from "@/lib/utils"

<Button className={cn("special-variant", className)}>
```

### 📱 Responsive Design

Toutes les pages utilisent :
- Grid responsive avec `md:grid-cols-*`
- Breakpoints Tailwind CSS
- Mobile-first approach
- Touch-friendly interactions

### 🔧 Configuration

#### **Components.json**
```json
{
  "style": "new-york",
  "rsc": true,
  "tsx": true,
  "tailwind": {
    "config": "",
    "css": "src/app/globals.css",
    "baseColor": "neutral",
    "cssVariables": true
  }
}
```

#### **Aliases Configurés**
- `@/components` → `src/components`
- `@/lib` → `src/lib`
- `@/ui` → `src/components/ui`

### 🎨 Guidelines de Design

#### **Couleurs**
- **Primary** : Actions principales, liens importants
- **Secondary** : Actions secondaires, backgrounds
- **Muted** : Texte secondaire, placeholders
- **Destructive** : Erreurs, suppressions

#### **Espacements**
- Utiliser les classes Tailwind standards
- Privilégier `space-y-*` et `gap-*`
- Respecter la hiérarchie visuelle

#### **Typography**
- Utiliser les classes `text-*` de Tailwind
- Respecter les tailles : `text-sm`, `text-base`, `text-lg`, etc.
- Utiliser `font-medium` et `font-semibold` pour l'emphase

### 🌟 Fonctionnalités Avancées

#### **Animations**
```tsx
// Transitions automatiques
<Card className="transition-all duration-300 hover:scale-105">
```

#### **États de Chargement**
```tsx
<Button disabled={isLoading}>
  {isLoading && <Spinner className="mr-2" />}
  {isLoading ? "Loading..." : "Submit"}
</Button>
```

#### **Gestion d'Erreurs**
```tsx
<ErrorMessage 
  message={error} 
  onDismiss={clearError}
  variant="error" 
/>
```

### 📚 Ressources

- [Shadcn/UI Documentation](https://ui.shadcn.com)
- [Tailwind CSS](https://tailwindcss.com)
- [Next.js Themes](https://github.com/pacocoursey/next-themes)
- [Lucide Icons](https://lucide.dev)

---

Ce template offre maintenant une base solide pour créer des interfaces modernes et professionnelles avec tous les outils nécessaires pré-configurés ! 🚀