#!/usr/bin/env node
// Describe a brandbook page image using Gemini Vision.
// Usage: node describe-page.mjs <image-path>
// Output: structured JSON to stdout

import { GoogleGenAI } from "@google/genai";
import fs from "fs";
import path from "path";

const imagePath = process.argv[2];
if (!imagePath) {
  console.error("Usage: node describe-page.mjs <image-path>");
  process.exit(1);
}

if (!fs.existsSync(imagePath)) {
  console.error(`Error: Image not found: ${imagePath}`);
  process.exit(1);
}

const apiKey = process.env.GEMINI_API_KEY;
if (!apiKey) {
  console.error("Error: GEMINI_API_KEY not set");
  process.exit(1);
}

const PROMPT = `Analyze this brandbook page as an expert art director with 30 years of experience.

Return ONLY valid JSON (no markdown, no code fences):
{
  "category": "logo|grid|3d|palette|typography|mockup|moodboard|ui|cover|icon|companion|poster|clear_zone|font_exploration|applications",
  "brand_name": "the brand name visible on this page, or 'unknown'",
  "methodology_step": "cover|challenge|decomposition|grid|3d_render|palette|applications|lockup|moodboard|font_exploration|typography_specimen|clear_zone|ui_design|icons|companions|posters|app_icon|favicon",
  "description": "Detailed visual description: composition, colors (hex if visible), typography, materials, lighting, layout structure, grid ratios if visible. Be specific about dimensions, proportions, and techniques used.",
  "hex_colors": ["#hex1", "#hex2"],
  "fonts_detected": ["Font Name 1"],
  "grid_ratios": ["X/1.4", "X/2.36"],
  "materials": ["frosted glass", "titanium"],
  "quality_notes": "What makes this page professional — specific techniques, attention to detail"
}

Rules:
- hex_colors: extract ALL visible hex codes or estimate dominant colors
- fonts_detected: identify font families from visual appearance
- grid_ratios: only if construction grid lines are visible
- materials: only for 3D renders or textured surfaces
- Be precise about spatial relationships and proportions`;

const client = new GoogleGenAI({ apiKey });

const imageData = fs.readFileSync(imagePath);
const ext = path.extname(imagePath).toLowerCase();
const mimeMap = { ".png": "image/png", ".jpg": "image/jpeg", ".jpeg": "image/jpeg", ".webp": "image/webp", ".svg": "image/svg+xml" };
const mimeType = mimeMap[ext] || "image/png";

try {
  const response = await client.models.generateContent({
    model: "gemini-2.0-flash",
    contents: [{
      parts: [
        { inlineData: { mimeType, data: imageData.toString("base64") } },
        { text: PROMPT }
      ]
    }]
  });

  const text = response.candidates?.[0]?.content?.parts?.[0]?.text || "";

  // Extract JSON from response (handle possible markdown wrapping)
  const jsonMatch = text.match(/\{[\s\S]*\}/);
  if (!jsonMatch) {
    console.error(`Error: No JSON found in response for ${imagePath}`);
    console.error(`Raw response: ${text.slice(0, 200)}`);
    process.exit(1);
  }

  const parsed = JSON.parse(jsonMatch[0]);

  // Normalize arrays
  parsed.hex_colors = parsed.hex_colors || [];
  parsed.fonts_detected = parsed.fonts_detected || [];
  parsed.grid_ratios = parsed.grid_ratios || [];
  parsed.materials = parsed.materials || [];

  console.log(JSON.stringify(parsed));
} catch (err) {
  if (err.status === 429 || err.status === 503) {
    console.error(`Rate limited on ${imagePath}, retry after delay`);
    process.exit(2); // Special exit code for retry
  }
  console.error(`Error describing ${imagePath}: ${err.message}`);
  process.exit(1);
}
