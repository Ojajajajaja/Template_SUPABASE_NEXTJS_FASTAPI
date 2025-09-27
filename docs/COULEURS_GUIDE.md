# 🎨 Guide de Personnalisation des Couleurs Shadcn/UI

## 📍 Où Modifier les Couleurs

Toutes les couleurs sont centralisées dans **un seul fichier** :
```
📁 frontend/src/app/globals.css
```

## 🌈 Variables de Couleurs Disponibles

### **Couleurs Principales**
```css
:root {
  /* Couleurs de fond */
  --background: oklch(1 0 0);          /* Fond principal */
  --foreground: oklch(0.145 0 0);      /* Texte principal */
  
  /* Couleurs des cartes */
  --card: oklch(1 0 0);                /* Fond des cards */
  --card-foreground: oklch(0.145 0 0); /* Texte des cards */
  
  /* Couleur primaire */
  --primary: oklch(0.205 0 0);         /* Boutons, liens */
  --primary-foreground: oklch(0.985 0 0); /* Texte sur primary */
  
  /* Couleur secondaire */
  --secondary: oklch(0.97 0 0);        /* Fond secondaire */
  --secondary-foreground: oklch(0.205 0 0); /* Texte secondaire */
  
  /* Couleurs atténuées */
  --muted: oklch(0.97 0 0);            /* Fond atténué */
  --muted-foreground: oklch(0.556 0 0); /* Texte atténué */
  
  /* Couleur d'accent */
  --accent: oklch(0.97 0 0);           /* Accent/highlight */
  --accent-foreground: oklch(0.205 0 0); /* Texte sur accent */
  
  /* Couleur destructive */
  --destructive: oklch(0.577 0.245 27.325); /* Erreurs, suppression */
  
  /* Bordures et contours */
  --border: oklch(0.922 0 0);          /* Bordures */
  --input: oklch(0.922 0 0);           /* Bordures des inputs */
  --ring: oklch(0.708 0 0);            /* Contours de focus */
  
  /* Rayon des bordures */
  --radius: 0.625rem;                  /* Arrondi des composants */
}
```

### **Mode Sombre**
```css
.dark {
  --background: oklch(0.145 0 0);      /* Fond sombre */
  --foreground: oklch(0.985 0 0);      /* Texte clair */
  --card: oklch(0.205 0 0);            /* Cards sombres */
  --primary: oklch(0.922 0 0);         /* Primary clair */
  /* ... autres couleurs inversées */
}
```

## 🛠 Comment Personnaliser

### **1. Changer la Couleur Primaire**
```css
:root {
  --primary: oklch(0.5 0.2 250);      /* Bleu moderne */
  --primary-foreground: oklch(1 0 0); /* Blanc */
}

.dark {
  --primary: oklch(0.7 0.2 250);      /* Bleu plus clair en mode sombre */
}
```

### **2. Créer un Thème Vert**
```css
:root {
  --primary: oklch(0.5 0.15 140);     /* Vert */
  --accent: oklch(0.6 0.1 120);       /* Vert clair */
  --destructive: oklch(0.5 0.2 30);   /* Orange pour erreurs */
}
```

### **3. Thème Violet/Rose**
```css
:root {
  --primary: oklch(0.55 0.2 300);     /* Violet */
  --accent: oklch(0.65 0.15 320);     /* Rose */
  --secondary: oklch(0.95 0.02 310);  /* Fond violet très clair */
}
```

## 🎯 Classes Tailwind Correspondantes

Les variables CSS sont automatiquement mappées vers ces classes :

| Variable CSS | Classe Tailwind | Usage |
|--------------|-----------------|--------|
| `--background` | `bg-background` | Fond principal |
| `--foreground` | `text-foreground` | Texte principal |
| `--primary` | `bg-primary` | Boutons, accents |
| `--muted-foreground` | `text-muted-foreground` | Texte secondaire |
| `--border` | `border-border` | Bordures |
| `--card` | `bg-card` | Fond des cartes |

## 📝 Exemple d'Usage dans les Composants

```tsx
// ✅ Correct - Utilise les variables Shadcn/UI
<div className="bg-card text-card-foreground border-border">
  <h2 className="text-foreground">Titre</h2>
  <p className="text-muted-foreground">Description</p>
  <Button className="bg-primary text-primary-foreground">Action</Button>
</div>

// ❌ Incorrect - Couleurs hardcodées
<div className="bg-white text-gray-900 border-gray-200">
  <h2 className="text-black">Titre</h2>
  <p className="text-gray-500">Description</p>
  <button className="bg-blue-600 text-white">Action</button>
</div>
```

## 🔄 Changements Automatiques

Quand vous modifiez les variables dans `globals.css`, **TOUS** les composants s'adaptent automatiquement :

- ✅ Boutons
- ✅ Cards
- ✅ Inputs
- ✅ Navigation
- ✅ Modales
- ✅ Tooltips
- ✅ Et tous les autres composants !

## 🌙 Support du Mode Sombre

Le système gère automatiquement :
- **Thème clair** (`:root`)
- **Thème sombre** (`.dark`)  
- **Thème système** (détection automatique)

## 🎨 Outils Recommandés

### **Générateur de Couleurs OKLCH**
- [OKLCH Color Picker](https://oklch.com)
- [Coolors.co](https://coolors.co)

### **Tester vos Couleurs**
```css
/* Testez rapidement une nouvelle palette */
:root {
  --primary: oklch(0.6 0.2 200);     /* Votre couleur */
}
```

## 💡 Conseils Pratiques

1. **Commencez par `--primary`** - C'est la couleur la plus visible
2. **Gardez la cohérence** - Utilisez la même teinte pour primary/accent
3. **Testez en mode sombre** - Assurez-vous que les couleurs restent lisibles
4. **Respectez l'accessibilité** - Contraste minimum 4.5:1 pour le texte

---

Avec ce système centralisé, **une seule modification** dans `globals.css` transforme instantanément toute votre interface ! 🚀