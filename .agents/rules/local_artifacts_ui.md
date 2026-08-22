---
name: Local Artifacts Screen Switcher
description: Enforces a smooth animated screen switcher widget for all React/Vite Local Artifact demos.
trigger: always_on
---

When generating or updating 'Local Artifacts' (React/Vite) code, you MUST:
1. **Multi-screen Support:** Create screens as separate components.
2. **Screen Switcher Widget:** Add a floating widget in the top/bottom right corner with < x > buttons to switch screens, and display the screen name.
3. **Smooth Animation:** Use 'framer-motion' or Tailwind transitions for smooth cross-fading or sliding between screens.
