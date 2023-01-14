import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import createReScriptPlugin from "@jihchi/vite-plugin-rescript";

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react(), createReScriptPlugin()],
  build: {
    rollupOptions: {
      output: {
        assetFileNames: ({ name }) => {
          console.log(name);
          if (/\.(gif|jpe?g|png|svg)$/.test(name ?? "")) {
            return "assets/images/[name]-[hash][extname]";
          }
          // default value
          // ref: https://rollupjs.org/guide/en/#outputassetfilenames
          return "assets/[name]-[hash][extname]";
        }
      }
    }
  }
});
