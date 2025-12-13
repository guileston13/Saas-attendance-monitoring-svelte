// vite.config.js
import { sveltekit } from "file:///C:/Users/Administrator/Documents/06%20Software%20Development/Web%20Development/Svelte/Saas-attendance-monitoring-svelte/node_modules/@sveltejs/kit/src/exports/vite/index.js";
import { defineConfig } from "file:///C:/Users/Administrator/Documents/06%20Software%20Development/Web%20Development/Svelte/Saas-attendance-monitoring-svelte/node_modules/vite/dist/node/index.js";
import fs from "fs";
var vite_config_default = defineConfig({
  plugins: [sveltekit()],
  // Exclude model binary files from being processed as JS
  assetsInclude: ["**/*.onnx"],
  optimizeDeps: {
    exclude: ["face-api.js"]
  },
  server: {
    host: true,
    // listen on all interfaces
    port: 4173,
    https: {
      key: fs.readFileSync("./localhost+1-key.pem"),
      cert: fs.readFileSync("./localhost+1.pem")
    },
    allowedHosts: [
      "localhost",
      "desktop-r98pm6a.local",
      "raspberrypi.local",
      // add your Pi here
      "172.27.44.17",
      "172.27.44.73",
      "172.27.44.213",
      "10.136.35.91",
      "192.168.100.15",
      "192.168.56.1",
      "192.168.1.64"
    ],
    fs: {
      allow: [
        "src",
        "node_modules"
      ]
    }
  },
  preview: {
    host: true,
    port: 4173,
    https: {
      key: fs.readFileSync("./localhost+1-key.pem"),
      cert: fs.readFileSync("./localhost+1.pem")
    },
    allowedHosts: [
      "localhost",
      "desktop-r98pm6a.local",
      "raspberrypi.local",
      // add your Pi here
      "172.27.44.17",
      "172.27.44.73",
      "172.27.44.213",
      "10.136.35.91",
      "192.168.56.1",
      "192.168.100.15",
      "192.168.56.1"
    ]
    // ✅ fs cannot go here
  }
});
export {
  vite_config_default as default
};
//# sourceMappingURL=data:application/json;base64,ewogICJ2ZXJzaW9uIjogMywKICAic291cmNlcyI6IFsidml0ZS5jb25maWcuanMiXSwKICAic291cmNlc0NvbnRlbnQiOiBbImNvbnN0IF9fdml0ZV9pbmplY3RlZF9vcmlnaW5hbF9kaXJuYW1lID0gXCJDOlxcXFxVc2Vyc1xcXFxBZG1pbmlzdHJhdG9yXFxcXERvY3VtZW50c1xcXFwwNiBTb2Z0d2FyZSBEZXZlbG9wbWVudFxcXFxXZWIgRGV2ZWxvcG1lbnRcXFxcU3ZlbHRlXFxcXFNhYXMtYXR0ZW5kYW5jZS1tb25pdG9yaW5nLXN2ZWx0ZVwiO2NvbnN0IF9fdml0ZV9pbmplY3RlZF9vcmlnaW5hbF9maWxlbmFtZSA9IFwiQzpcXFxcVXNlcnNcXFxcQWRtaW5pc3RyYXRvclxcXFxEb2N1bWVudHNcXFxcMDYgU29mdHdhcmUgRGV2ZWxvcG1lbnRcXFxcV2ViIERldmVsb3BtZW50XFxcXFN2ZWx0ZVxcXFxTYWFzLWF0dGVuZGFuY2UtbW9uaXRvcmluZy1zdmVsdGVcXFxcdml0ZS5jb25maWcuanNcIjtjb25zdCBfX3ZpdGVfaW5qZWN0ZWRfb3JpZ2luYWxfaW1wb3J0X21ldGFfdXJsID0gXCJmaWxlOi8vL0M6L1VzZXJzL0FkbWluaXN0cmF0b3IvRG9jdW1lbnRzLzA2JTIwU29mdHdhcmUlMjBEZXZlbG9wbWVudC9XZWIlMjBEZXZlbG9wbWVudC9TdmVsdGUvU2Fhcy1hdHRlbmRhbmNlLW1vbml0b3Jpbmctc3ZlbHRlL3ZpdGUuY29uZmlnLmpzXCI7Ly8gdml0ZS5jb25maWcuanNcclxuaW1wb3J0IHsgc3ZlbHRla2l0IH0gZnJvbSAnQHN2ZWx0ZWpzL2tpdC92aXRlJztcclxuaW1wb3J0IHsgZGVmaW5lQ29uZmlnIH0gZnJvbSAndml0ZSc7XHJcbmltcG9ydCBmcyBmcm9tICdmcyc7XHJcbmltcG9ydCBwYXRoIGZyb20gJ3BhdGgnO1xyXG5cclxuZXhwb3J0IGRlZmF1bHQgZGVmaW5lQ29uZmlnKHtcclxuICBwbHVnaW5zOiBbc3ZlbHRla2l0KCldLFxyXG5cclxuICAvLyBFeGNsdWRlIG1vZGVsIGJpbmFyeSBmaWxlcyBmcm9tIGJlaW5nIHByb2Nlc3NlZCBhcyBKU1xyXG4gIGFzc2V0c0luY2x1ZGU6IFsnKiovKi5vbm54J10sXHJcbiAgXHJcbiAgb3B0aW1pemVEZXBzOiB7XHJcbiAgICBleGNsdWRlOiBbJ2ZhY2UtYXBpLmpzJ11cclxuICB9LFxyXG5cclxuICBzZXJ2ZXI6IHtcclxuICAgIGhvc3Q6IHRydWUsICAvLyBsaXN0ZW4gb24gYWxsIGludGVyZmFjZXNcclxuICAgIHBvcnQ6IDQxNzMsXHJcbiAgICBodHRwczoge1xyXG4gICAgICBrZXk6IGZzLnJlYWRGaWxlU3luYygnLi9sb2NhbGhvc3QrMS1rZXkucGVtJyksXHJcbiAgICAgIGNlcnQ6IGZzLnJlYWRGaWxlU3luYygnLi9sb2NhbGhvc3QrMS5wZW0nKVxyXG4gICAgfSxcclxuICAgIGFsbG93ZWRIb3N0czogW1xyXG4gICAgICAnbG9jYWxob3N0JyxcclxuICAgICAgJ2Rlc2t0b3Atcjk4cG02YS5sb2NhbCcsXHJcbiAgICAgICdyYXNwYmVycnlwaS5sb2NhbCcsIC8vIGFkZCB5b3VyIFBpIGhlcmVcclxuICAgICAgJzE3Mi4yNy40NC4xNycsXHJcbiAgICAgICcxNzIuMjcuNDQuNzMnLFxyXG4gICAgICAnMTcyLjI3LjQ0LjIxMycsXHJcbiAgICAgICcxMC4xMzYuMzUuOTEnLFxyXG4gICAgICAnMTkyLjE2OC4xMDAuMTUnLFxyXG4gICAgICAnMTkyLjE2OC41Ni4xJyxcclxuICAgICAgJzE5Mi4xNjguMS42NCcsXHJcbiAgICAgIFxyXG4gICAgXSxcclxuICAgIGZzOiB7XHJcbiAgICAgIGFsbG93OiBbXHJcbiAgICAgICAgJ3NyYycsXHJcbiAgICAgICAgJ25vZGVfbW9kdWxlcydcclxuICAgICAgXVxyXG4gICAgfVxyXG4gIH0sXHJcblxyXG4gIHByZXZpZXc6IHtcclxuICAgIGhvc3Q6IHRydWUsXHJcbiAgICBwb3J0OiA0MTczLFxyXG4gICAgaHR0cHM6IHtcclxuICAgICAga2V5OiBmcy5yZWFkRmlsZVN5bmMoJy4vbG9jYWxob3N0KzEta2V5LnBlbScpLFxyXG4gICAgICBjZXJ0OiBmcy5yZWFkRmlsZVN5bmMoJy4vbG9jYWxob3N0KzEucGVtJylcclxuICAgIH0sXHJcbiAgICBhbGxvd2VkSG9zdHM6IFtcclxuICAgICAgJ2xvY2FsaG9zdCcsXHJcbiAgICAgICdkZXNrdG9wLXI5OHBtNmEubG9jYWwnLFxyXG4gICAgICAncmFzcGJlcnJ5cGkubG9jYWwnLCAvLyBhZGQgeW91ciBQaSBoZXJlXHJcbiAgICAgICcxNzIuMjcuNDQuMTcnLFxyXG4gICAgICAnMTcyLjI3LjQ0LjczJyxcclxuICAgICAgJzE3Mi4yNy40NC4yMTMnLFxyXG4gICAgICAnMTAuMTM2LjM1LjkxJyxcclxuICAgICAgJzE5Mi4xNjguNTYuMScsXHJcbiAgICAgICcxOTIuMTY4LjEwMC4xNScsXHJcbiAgICAgICcxOTIuMTY4LjU2LjEnXHJcbiAgICBdXHJcbiAgICAvLyBcdTI3MDUgZnMgY2Fubm90IGdvIGhlcmVcclxuICB9XHJcbn0pO1xyXG4iXSwKICAibWFwcGluZ3MiOiAiO0FBQ0EsU0FBUyxpQkFBaUI7QUFDMUIsU0FBUyxvQkFBb0I7QUFDN0IsT0FBTyxRQUFRO0FBR2YsSUFBTyxzQkFBUSxhQUFhO0FBQUEsRUFDMUIsU0FBUyxDQUFDLFVBQVUsQ0FBQztBQUFBO0FBQUEsRUFHckIsZUFBZSxDQUFDLFdBQVc7QUFBQSxFQUUzQixjQUFjO0FBQUEsSUFDWixTQUFTLENBQUMsYUFBYTtBQUFBLEVBQ3pCO0FBQUEsRUFFQSxRQUFRO0FBQUEsSUFDTixNQUFNO0FBQUE7QUFBQSxJQUNOLE1BQU07QUFBQSxJQUNOLE9BQU87QUFBQSxNQUNMLEtBQUssR0FBRyxhQUFhLHVCQUF1QjtBQUFBLE1BQzVDLE1BQU0sR0FBRyxhQUFhLG1CQUFtQjtBQUFBLElBQzNDO0FBQUEsSUFDQSxjQUFjO0FBQUEsTUFDWjtBQUFBLE1BQ0E7QUFBQSxNQUNBO0FBQUE7QUFBQSxNQUNBO0FBQUEsTUFDQTtBQUFBLE1BQ0E7QUFBQSxNQUNBO0FBQUEsTUFDQTtBQUFBLE1BQ0E7QUFBQSxNQUNBO0FBQUEsSUFFRjtBQUFBLElBQ0EsSUFBSTtBQUFBLE1BQ0YsT0FBTztBQUFBLFFBQ0w7QUFBQSxRQUNBO0FBQUEsTUFDRjtBQUFBLElBQ0Y7QUFBQSxFQUNGO0FBQUEsRUFFQSxTQUFTO0FBQUEsSUFDUCxNQUFNO0FBQUEsSUFDTixNQUFNO0FBQUEsSUFDTixPQUFPO0FBQUEsTUFDTCxLQUFLLEdBQUcsYUFBYSx1QkFBdUI7QUFBQSxNQUM1QyxNQUFNLEdBQUcsYUFBYSxtQkFBbUI7QUFBQSxJQUMzQztBQUFBLElBQ0EsY0FBYztBQUFBLE1BQ1o7QUFBQSxNQUNBO0FBQUEsTUFDQTtBQUFBO0FBQUEsTUFDQTtBQUFBLE1BQ0E7QUFBQSxNQUNBO0FBQUEsTUFDQTtBQUFBLE1BQ0E7QUFBQSxNQUNBO0FBQUEsTUFDQTtBQUFBLElBQ0Y7QUFBQTtBQUFBLEVBRUY7QUFDRixDQUFDOyIsCiAgIm5hbWVzIjogW10KfQo=
