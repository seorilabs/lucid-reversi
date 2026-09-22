import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

import aitDevtools from "@apps-in-toss/devtools/unplugin";

// Godot Web export(public/godot/*)는 정적 자산으로 그대로 서빙된다.
export default defineConfig({
  plugins: [aitDevtools.vite(), react()],
  server: {
    port: 5173,
  },
});
