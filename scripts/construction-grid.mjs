#!/usr/bin/env node
// Construction Grid SVG Generator
// Generates parametric SVG construction grids based on GST Agency methodology.
// Zero npm dependencies — pure Node.js string templates.
//
// Usage:
//   node scripts/construction-grid.mjs --width 512 --height 512 [options]
//
// Options:
//   --width <px>          Logo width (required)
//   --height <px>         Logo height (required)
//   --ratios <list>       Comma-separated ratio divisors (default: "1,1.4,1.5,2.36")
//   --grid-type <type>    Grid type: square|circle (default: square)
//   --grid-columns <n>    Grid columns (default: 8)
//   --grid-rows <n>       Grid rows (default: 20)
//   --guides <list>       Guide lines: cap,median,baseline,descender (default: all)
//   --primary-color <hex> Primary color for ratio lines (default: "#7c3aed")
//   --grid-color <hex>    Grid line color (default: "#888888")
//   --output <path>       Output SVG path (default: stdout)

import fs from "fs";
import path from "path";

function parseArgs(argv) {
  const args = {};
  for (let i = 0; i < argv.length; i++) {
    if (argv[i] === "--help" || argv[i] === "-h") {
      console.log("Usage: node construction-grid.mjs --width <px> --height <px> [--ratios 1,1.4,1.5,2.36] [--output file.svg]");
      process.exit(0);
    }
    if (argv[i].startsWith("--") && i + 1 < argv.length) {
      args[argv[i].slice(2)] = argv[i + 1];
      i++;
    }
  }
  return args;
}

const args = parseArgs(process.argv.slice(2));

const W = parseInt(args.width, 10);
const H = parseInt(args.height, 10);

if (!W || !H) {
  console.error("Error: --width and --height are required.");
  process.exit(1);
}

const ratios = (args.ratios || "1,1.4,1.5,2.36").split(",").map(Number);
const gridType = args["grid-type"] || "square";
const cols = parseInt(args["grid-columns"] || "8", 10);
const rows = parseInt(args["grid-rows"] || "20", 10);
const guides = (args.guides || "cap,median,baseline,descender").split(",");
const primaryColor = args["primary-color"] || "#7c3aed";
const gridColor = args["grid-color"] || "#888888";
const outputPath = args.output || null;

// Padding around the logo area
const PAD = Math.round(Math.min(W, H) * 0.15);
const TOTAL_W = W + PAD * 2;
const TOTAL_H = H + PAD * 2;
const CX = TOTAL_W / 2;
const CY = TOTAL_H / 2;

// Guide line positions (percentage of logo height, measured from top of logo area)
const GUIDE_POSITIONS = {
  cap: 0.12,
  median: 0.38,
  baseline: 0.72,
  descender: 0.88,
};

// Ratio line styles
const RATIO_STYLES = [
  { dash: "none", width: 1.5 },
  { dash: "8,4", width: 1.2 },
  { dash: "4,4", width: 1.0 },
  { dash: "2,4", width: 0.8 },
  { dash: "12,4,2,4", width: 0.8 },
];

function buildGrid() {
  const lines = [];
  const cellW = W / cols;
  const cellH = H / rows;

  // Vertical lines
  for (let c = 0; c <= cols; c++) {
    const x = PAD + c * cellW;
    lines.push(`<line x1="${x}" y1="${PAD}" x2="${x}" y2="${PAD + H}" />`);
  }
  // Horizontal lines
  for (let r = 0; r <= rows; r++) {
    const y = PAD + r * cellH;
    lines.push(`<line x1="${PAD}" y1="${y}" x2="${PAD + W}" y2="${y}" />`);
  }
  return lines.join("\n    ");
}

function buildRatios() {
  const elements = [];
  const maxR = Math.min(W, H) / 2;

  ratios.forEach((ratio, i) => {
    const style = RATIO_STYLES[i % RATIO_STYLES.length];
    const r = maxR / ratio;
    const dashAttr = style.dash === "none" ? "" : ` stroke-dasharray="${style.dash}"`;

    if (gridType === "circle") {
      elements.push(`<circle cx="${CX}" cy="${CY}" r="${r.toFixed(1)}"${dashAttr} stroke-width="${style.width}" />`);
    } else {
      // Square/rectangle ratio guides
      const halfW = (W / 2) / ratio;
      const halfH = (H / 2) / ratio;
      elements.push(`<rect x="${(CX - halfW).toFixed(1)}" y="${(CY - halfH).toFixed(1)}" width="${(halfW * 2).toFixed(1)}" height="${(halfH * 2).toFixed(1)}"${dashAttr} stroke-width="${style.width}" rx="1" />`);
      // Also add circle for this ratio
      elements.push(`<circle cx="${CX}" cy="${CY}" r="${r.toFixed(1)}"${dashAttr} stroke-width="${style.width}" />`);
    }

    // Label
    const labelY = CY - r - 6;
    elements.push(`<text x="${CX}" y="${labelY}" text-anchor="middle" font-size="10" fill="${primaryColor}" opacity="0.7" font-family="monospace">X/${ratio}</text>`);
  });

  return elements.join("\n    ");
}

function buildGuides() {
  const lines = [];
  const guideColors = {
    cap: "#ef4444",
    median: "#3b82f6",
    baseline: "#22c55e",
    descender: "#f59e0b",
  };

  for (const guide of guides) {
    const pos = GUIDE_POSITIONS[guide];
    if (pos === undefined) continue;

    const y = PAD + H * pos;
    const color = guideColors[guide] || "#888";

    lines.push(`<line x1="${PAD - 20}" y1="${y}" x2="${PAD + W + 20}" y2="${y}" stroke="${color}" stroke-width="0.8" stroke-dasharray="6,3" />`);
    lines.push(`<text x="${PAD - 24}" y="${y + 3}" text-anchor="end" font-size="9" fill="${color}" font-family="monospace">${guide}</text>`);
  }

  return lines.join("\n    ");
}

function buildLogoOutline() {
  return `<rect x="${PAD}" y="${PAD}" width="${W}" height="${H}" rx="2" />`;
}

function buildDimensions() {
  const labels = [];
  // Width dimension
  labels.push(`<line x1="${PAD}" y1="${TOTAL_H - 10}" x2="${PAD + W}" y2="${TOTAL_H - 10}" stroke="${gridColor}" stroke-width="0.5" />`);
  labels.push(`<text x="${CX}" y="${TOTAL_H - 2}" text-anchor="middle" font-size="9" fill="${gridColor}" font-family="monospace">${W}px</text>`);
  // Height dimension
  labels.push(`<line x1="${TOTAL_W - 10}" y1="${PAD}" x2="${TOTAL_W - 10}" y2="${PAD + H}" stroke="${gridColor}" stroke-width="0.5" />`);
  labels.push(`<text x="${TOTAL_W - 2}" y="${CY}" text-anchor="start" font-size="9" fill="${gridColor}" font-family="monospace" transform="rotate(90,${TOTAL_W - 2},${CY})">${H}px</text>`);
  return labels.join("\n    ");
}

const svg = `<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${TOTAL_W} ${TOTAL_H}" width="${TOTAL_W}" height="${TOTAL_H}">
  <title>Construction Grid — ${W}x${H} — Ratios: ${ratios.join(", ")}</title>
  <desc>Parametric construction grid generated by claude-creative-studio. GST Agency methodology.</desc>

  <!-- Background -->
  <rect width="100%" height="100%" fill="#09090b" />

  <!-- Grid: ${cols}x${rows} -->
  <g id="grid" stroke="${gridColor}" stroke-width="0.3" opacity="0.15" fill="none">
    ${buildGrid()}
  </g>

  <!-- Ratio guides: ${ratios.join(", ")} -->
  <g id="ratios" stroke="${primaryColor}" fill="none" opacity="0.5">
    ${buildRatios()}
  </g>

  <!-- Typography guides -->
  <g id="guides" fill="none">
    ${buildGuides()}
  </g>

  <!-- Logo bounding box -->
  <g id="logo-outline" stroke="${primaryColor}" stroke-width="1" fill="none" opacity="0.12" stroke-dasharray="4,2">
    ${buildLogoOutline()}
  </g>

  <!-- Dimensions -->
  <g id="dimensions" opacity="0.4">
    ${buildDimensions()}
  </g>
</svg>`;

if (outputPath) {
  const dir = path.dirname(outputPath);
  fs.mkdirSync(dir, { recursive: true });
  fs.writeFileSync(outputPath, svg, "utf-8");
  console.log(`Generated: ${outputPath} (${TOTAL_W}x${TOTAL_H})`);
} else {
  process.stdout.write(svg);
}
