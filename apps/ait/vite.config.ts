import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

// Godot Web export(public/godot/*)는 정적 자산으로 그대로 서빙된다.
export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
  },
});
