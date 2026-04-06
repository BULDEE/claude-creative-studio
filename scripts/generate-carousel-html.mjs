#!/usr/bin/env node
// Carousel HTML Generator
// Generates a self-contained branded HTML file with carousel slides from data files.
// Zero npm dependencies — pure Node.js string templates.
//
// Usage:
//   node scripts/generate-carousel-html.mjs \
//     --brand /path/to/brand.json \
//     --carousel /path/to/carousel.json \
//     --copy /path/to/copy.md \
//     --output /path/to/slides.html
//
// Options:
//   --brand <path>     Path to brand.json (required)
//   --carousel <path>  Path to carousel.json (required)
//   --copy <path>      Path to copy.md (required)
//   --output <path>    Output HTML path (default: stdout)
//   --help, -h         Show this help message

import fs from "fs";
import path from "path";

// ---------------------------------------------------------------------------
// CLI
// ---------------------------------------------------------------------------

function printHelp() {
  console.log(`
Carousel HTML Generator
=======================
Generates a self-contained branded HTML carousel from brand, carousel, and copy files.

Usage:
  node generate-carousel-html.mjs --brand brand.json --carousel carousel.json --copy copy.md [--output slides.html]

Options:
  --brand <path>     Path to brand.json (required)
  --carousel <path>  Path to carousel.json (required)
  --copy <path>      Path to copy.md (required)
  --output <path>    Output HTML path (default: stdout)
  --help, -h         Show this help message
  `.trim());
}

function parseArgs(argv) {
  const args = {};
  for (let i = 0; i < argv.length; i++) {
    if (argv[i] === "--help" || argv[i] === "-h") {
      printHelp();
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

if (!args.brand || !args.carousel || !args.copy) {
  console.error("Error: --brand, --carousel, and --copy are required.");
  console.error("Run with --help for usage information.");
  process.exit(1);
}

// ---------------------------------------------------------------------------
// File loading
// ---------------------------------------------------------------------------

function readFileOrExit(filePath, label) {
  const resolved = path.resolve(filePath);
  if (!fs.existsSync(resolved)) {
    console.error(`Error: ${label} file not found: ${resolved}`);
    process.exit(1);
  }
  return fs.readFileSync(resolved, "utf-8");
}

function parseJsonOrExit(content, filePath) {
  try {
    return JSON.parse(content);
  } catch (err) {
    console.error(`Error: Failed to parse JSON from ${filePath}: ${err.message}`);
    process.exit(1);
  }
}

const brandRaw = readFileOrExit(args.brand, "brand");
const carouselRaw = readFileOrExit(args.carousel, "carousel");
const copyRaw = readFileOrExit(args.copy, "copy");

const brand = parseJsonOrExit(brandRaw, args.brand);
const carousel = parseJsonOrExit(carouselRaw, args.carousel);

// ---------------------------------------------------------------------------
// Token extraction from brand.json
// ---------------------------------------------------------------------------

function resolveColorHex(colorEntry) {
  if (typeof colorEntry === "string") return colorEntry;
  if (colorEntry && typeof colorEntry.hex === "string") return colorEntry.hex;
  return null;
}

function extractTokens(brandData) {
  const colors = brandData.colors || {};
  const typography = brandData.typography || {};

  const primaryHex = resolveColorHex(colors.primary) || "#CCFF00";
  const secondaryHex = resolveColorHex(colors.secondary) || "#FF2D8A";
  const accentHex = resolveColorHex(colors.accent) || "#FFE500";

  // Support both nested neutral object and top-level bg/surface fields
  const neutral = colors.neutral || {};
  const bgHex =
    resolveColorHex(colors.background) ||
    resolveColorHex(neutral.bg) ||
    "#0A0A0A";
  const surfaceHex =
    resolveColorHex(colors.surface) ||
    resolveColorHex(neutral.surface) ||
    "#1A1A1A";
  const foregroundHex =
    (colors.text && colors.text.primary) ||
    resolveColorHex(neutral.foreground) ||
    "#FFFFFF";
  const mutedHex =
    (colors.text && colors.text.secondary) ||
    resolveColorHex(neutral.muted) ||
    "#A0A0A0";
  const darkGrayHex =
    resolveColorHex(neutral.secondary) || "#666666";

  const displayFamily =
    (typography.display && typography.display.family) || "Space Grotesk";
  const bodyFamily =
    (typography.body && typography.body.family) || "Inter";
  const monoFamily =
    (typography.mono && typography.mono.family) || "JetBrains Mono";

  return {
    primaryHex,
    secondaryHex,
    accentHex,
    bgHex,
    surfaceHex,
    foregroundHex,
    mutedHex,
    darkGrayHex,
    displayFamily,
    bodyFamily,
    monoFamily,
    brandName: brandData.name || "Brand",
  };
}

const tokens = extractTokens(brand);

// ---------------------------------------------------------------------------
// Google Fonts URL builder
// ---------------------------------------------------------------------------

function buildGoogleFontsUrl(brandData) {
  const typography = brandData.typography || {};
  const families = [];

  const fontEntries = [
    typography.display,
    typography.heading,
    typography.body,
    typography.mono,
  ].filter(Boolean);

  const seen = new Set();
  for (const entry of fontEntries) {
    if (!entry.family || seen.has(entry.family)) continue;
    seen.add(entry.family);

    const weights = Array.isArray(entry.weights) && entry.weights.length > 0
      ? entry.weights
      : [400];

    const uniqueWeights = [...new Set(weights)].sort((a, b) => a - b);
    const weightStr = uniqueWeights.join(";");
    const encodedFamily = entry.family.replace(/ /g, "+");
    families.push(`family=${encodedFamily}:wght@${weightStr}`);
  }

  if (families.length === 0) return null;
  return `https://fonts.googleapis.com/css2?${families.join("&")}&display=swap`;
}

const googleFontsUrl = buildGoogleFontsUrl(brand);

// ---------------------------------------------------------------------------
// copy.md parser — split by "## Slide N" headers
// ---------------------------------------------------------------------------

function parseCopyMarkdown(copyContent) {
  // Split on lines starting with "## Slide " (case-insensitive)
  const sectionRegex = /^##\s+Slide\s+(\d+)/im;
  const lines = copyContent.split("\n");

  const sections = {};
  let currentSlide = null;
  const buffer = [];

  for (const line of lines) {
    const match = line.match(/^##\s+Slide\s+(\d+)/i);
    if (match) {
      if (currentSlide !== null) {
        sections[currentSlide] = buffer.join("\n").trim();
        buffer.length = 0;
      }
      currentSlide = parseInt(match[1], 10);
    } else if (currentSlide !== null) {
      buffer.push(line);
    }
  }

  // Flush last section
  if (currentSlide !== null && buffer.length > 0) {
    sections[currentSlide] = buffer.join("\n").trim();
  }

  return sections;
}

const copySections = parseCopyMarkdown(copyRaw);

// ---------------------------------------------------------------------------
// Copy extraction helpers
// ---------------------------------------------------------------------------

function stripMarkdownBold(text) {
  return text.replace(/\*\*([^*]+)\*\*/g, "$1");
}

// Extract plain text lines from a copy section, filtering markdown decorators
function extractTextLines(sectionContent) {
  return sectionContent
    .split("\n")
    .map((line) => line.trim())
    .filter((line) => line.length > 0)
    .filter((line) => !line.startsWith("---"))
    .filter((line) => !line.startsWith("**Hook"))
    .filter((line) => !line.startsWith("**Platform"))
    .filter((line) => !line.startsWith("**Format"))
    .map(stripMarkdownBold);
}

// Find all percentage numbers in a copy section (e.g. "73 %" or "73%")
function extractPercentages(sectionContent) {
  const matches = sectionContent.match(/(\d+)\s*%/g) || [];
  return matches.map((m) => m.replace(/\s/, ""));
}

// Extract lines that are followed by a description (for DATA slides)
// Returns array of { value, description } pairs
function extractDataPoints(sectionContent) {
  const lines = extractTextLines(sectionContent);
  const percentages = extractPercentages(sectionContent);
  const dataPoints = [];

  let pIndex = 0;
  for (const line of lines) {
    const pctMatch = line.match(/(\d+)\s*%/);
    if (pctMatch && pIndex < percentages.length) {
      const valueStr = percentages[pIndex];
      const description = line.replace(/\*?\*?(\d+)\s*%\*?\*?/, "").replace(/^\s*(des?|of|—|-|:)?\s*/i, "").trim();
      dataPoints.push({ value: valueStr, description });
      pIndex++;
    }
  }

  return dataPoints;
}

// Extract a "punchline" — typically the last non-empty line of a section
function extractPunchline(sectionContent) {
  const lines = extractTextLines(sectionContent);
  return lines[lines.length - 1] || "";
}

// Escape HTML special characters
function escHtml(str) {
  return String(str)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");
}

// ---------------------------------------------------------------------------
// Slide meta helpers
// ---------------------------------------------------------------------------

function slideLabel(slideNumber, totalSlides) {
  return `${String(slideNumber).padStart(2, "0")} / ${String(totalSlides).padStart(2, "0")}`;
}

function isLastSlide(slideNumber, totalSlides) {
  return slideNumber === totalSlides;
}

// ---------------------------------------------------------------------------
// Shared slide chrome (slide number, watermark, swipe indicator)
// ---------------------------------------------------------------------------

function buildSlideChrome(slideNumber, totalSlides, isLast, isCtaSlide) {
  const watermarkOpacity = isCtaSlide ? "1" : "0.4";
  const watermarkSize = isCtaSlide ? "24px" : "16px";
  const swipeIndicator = isLast
    ? ""
    : `<div class="swipe-indicator">Swipe →</div>`;

  return `
  <div class="slide-number">${escHtml(slideLabel(slideNumber, totalSlides))}</div>
  ${swipeIndicator}
  <div class="logo-watermark" style="opacity:${watermarkOpacity};font-size:${watermarkSize};">${escHtml(tokens.brandName)}</div>`.trim();
}

// ---------------------------------------------------------------------------
// Layout template: HOOK / TITLE
// ---------------------------------------------------------------------------

function buildHookSlide(slideEntry, copySection, slideNumber, totalSlides) {
  const lines = extractTextLines(copySection);
  const headline = escHtml(slideEntry.headline || lines[0] || "");
  const subtitle = escHtml(lines.find((l, i) => i > 0) || "");
  const brandUpper = escHtml(tokens.brandName.toUpperCase());
  const chrome = buildSlideChrome(slideNumber, totalSlides, false, false);

  return `
<!-- SLIDE ${slideNumber} — HOOK -->
<div class="slide" id="slide-${slideNumber}">
  <div class="orb orb-primary" style="width:500px;height:500px;top:-150px;right:-100px;"></div>
  <div class="orb orb-secondary" style="width:400px;height:400px;bottom:-100px;left:-100px;"></div>
  ${chrome}
  <div style="position:relative;z-index:1;">
    <div class="mono" style="font-size:13px;color:var(--primary);letter-spacing:0.15em;text-transform:uppercase;margin-bottom:40px;">${brandUpper} — Carousel</div>
    <h1 style="font-size:72px;max-width:800px;">${headline}</h1>
    ${subtitle ? `<p class="body-text" style="font-size:28px;margin-top:40px;max-width:700px;">${subtitle}</p>` : ""}
  </div>
</div>`.trim();
}

// ---------------------------------------------------------------------------
// Layout template: DATA
// ---------------------------------------------------------------------------

function buildDataSlide(slideEntry, copySection, slideNumber, totalSlides) {
  const punchline = escHtml(extractPunchline(copySection));
  const lines = extractTextLines(copySection);

  // Build data points: each line with a % is a stat; next line is description
  const dataBlocks = [];
  const percentages = extractPercentages(copySection);

  // Map each percentage to the line it appears in, then use the next line as description
  const rawLines = copySection.split("\n").map((l) => l.trim()).filter((l) => l.length > 0 && !l.startsWith("---"));

  let pctFound = 0;
  for (let i = 0; i < rawLines.length; i++) {
    const pctMatch = rawLines[i].match(/(\d+)\s*%/);
    if (pctMatch) {
      const value = pctMatch[1] + "%";
      // Description: rest of the line after the percent, or next non-bold line
      let description = rawLines[i].replace(/\*?\*?\d+\s*%\*?\*?/, "").replace(/^\s*(des?|of|—|-|:)?\s*/i, "").trim();
      if (!description && i + 1 < rawLines.length) {
        description = stripMarkdownBold(rawLines[i + 1]);
      }
      const color = pctFound === 0 ? "var(--primary)" : "var(--secondary)";
      dataBlocks.push({ value: escHtml(value), description: escHtml(description), color });
      pctFound++;
    }
  }

  const dataBlocksHtml = dataBlocks
    .map((block, idx) => {
      const divider = idx < dataBlocks.length - 1
        ? `<div style="width:120px;height:2px;background:var(--dark-gray);margin:50px auto;"></div>`
        : "";
      return `
    <div class="big-number text-glow" style="font-size:200px;color:${block.color};">${block.value}</div>
    <p class="body-text" style="font-size:24px;margin-top:10px;">${block.description}</p>
    ${divider}`.trim();
    })
    .join("\n    ");

  const chrome = buildSlideChrome(slideNumber, totalSlides, false, false);

  return `
<!-- SLIDE ${slideNumber} — DATA -->
<div class="slide" id="slide-${slideNumber}">
  <div class="orb orb-primary" style="width:600px;height:600px;top:50%;left:50%;transform:translate(-50%,-50%);opacity:0.05;"></div>
  ${chrome}
  <div style="position:relative;z-index:1;text-align:center;">
    ${dataBlocksHtml}
    <p style="font-size:22px;margin-top:60px;color:var(--foreground);font-weight:500;">${punchline}</p>
  </div>
</div>`.trim();
}

// ---------------------------------------------------------------------------
// Layout template: PAIN
// ---------------------------------------------------------------------------

function buildPainSlide(slideEntry, copySection, slideNumber, totalSlides) {
  const lines = extractTextLines(copySection);
  const mainLines = lines.slice(0, lines.length - 1);
  const footerLine = lines[lines.length - 1] || "";
  const chrome = buildSlideChrome(slideNumber, totalSlides, false, false);

  // Highlight the last word of the second-to-last main line in secondary color
  const bodyParagraphs = mainLines.map((line, idx) => {
    // Detect short punchy lines (< 30 chars) for impact
    const isShort = line.length < 30;
    const escapedLine = escHtml(line);
    // Highlight key negative word pattern at end of lines
    const highlighted = escapedLine.replace(
      /\b(non|jamais|rien|pas|echec|fail|stagnent)\b\.?$/i,
      (match) => `<span style="color:var(--secondary);">${match}</span>`
    );
    return `<p style="font-size:36px;line-height:1.7;color:var(--foreground);font-weight:400;${idx > 0 ? "margin-top:20px;" : ""}">${highlighted}</p>`;
  }).join("\n      ");

  return `
<!-- SLIDE ${slideNumber} — PAIN -->
<div class="slide" id="slide-${slideNumber}">
  ${chrome}
  <div style="position:relative;z-index:1;padding-left:40px;border-left:4px solid var(--secondary);">
    ${bodyParagraphs}
    ${footerLine ? `<p style="font-size:20px;margin-top:60px;color:var(--dark-gray);font-style:italic;">${escHtml(footerLine)}</p>` : ""}
  </div>
</div>`.trim();
}

// ---------------------------------------------------------------------------
// Layout template: SHIFT
// ---------------------------------------------------------------------------

function buildShiftSlide(slideEntry, copySection, slideNumber, totalSlides) {
  const lines = extractTextLines(copySection);
  const chrome = buildSlideChrome(slideNumber, totalSlides, false, false);

  // Find the keyword in bold (markdown **KEYWORD**)
  const boldMatch = copySection.match(/\*\*([^*]+)\*\*/);
  const highlightedKeyword = boldMatch ? boldMatch[1].toUpperCase() : "ANGLE";

  // Problem line (first), bridge line (second or second-to-last), resolution (last)
  const problemLine = escHtml(lines[0] || "");
  const resolutionLine = escHtml(lines[lines.length - 1] || "");

  // Build bridge text — everything between problem and resolution, joined
  const bridgeLines = lines.slice(1, lines.length - 1);
  // Remove the highlighted keyword from bridge text
  const bridgeText = escHtml(
    bridgeLines.join(" ").replace(new RegExp(`\\b${highlightedKeyword}\\b`, "i"), "").trim()
  );

  return `
<!-- SLIDE ${slideNumber} — SHIFT -->
<div class="slide" id="slide-${slideNumber}">
  ${chrome}
  <div style="position:relative;z-index:1;">
    <p class="body-text" style="font-size:28px;max-width:700px;">${problemLine}</p>
    ${bridgeText ? `<p style="font-size:28px;color:var(--foreground);margin-top:30px;max-width:700px;line-height:1.5;">${bridgeText}</p>` : ""}
    <div style="margin-top:40px;display:inline-block;background:var(--primary);padding:16px 48px;border-radius:8px;">
      <span style="font-family:var(--font-display);font-weight:700;font-size:64px;color:var(--bg);letter-spacing:-0.02em;">${escHtml(highlightedKeyword)}</span>
    </div>
    <p style="font-size:26px;color:var(--primary);margin-top:50px;font-weight:500;">${resolutionLine}</p>
  </div>
</div>`.trim();
}

// ---------------------------------------------------------------------------
// Layout template: SIGNAL (01-04)
// ---------------------------------------------------------------------------

// Signal colors cycle: 1-2 primary, 3 accent, 4 secondary
function signalColor(signalNumber) {
  if (signalNumber <= 2) return "var(--primary)";
  if (signalNumber === 3) return "var(--accent)";
  return "var(--secondary)";
}

function signalColorClass(signalNumber) {
  if (signalNumber <= 2) return "color:var(--primary)";
  if (signalNumber === 3) return "color:var(--accent)";
  return "color:var(--secondary)";
}

// Extract the signal number from a role string like "SIGNAL 01"
function parseSignalNumber(roleStr) {
  const match = roleStr.match(/(\d+)/);
  return match ? parseInt(match[1], 10) : 1;
}

// Detect if the copy section contains a list pattern (→ or bullet points)
function hasListPattern(sectionContent) {
  return /→|^\s*[-•*]\s/m.test(sectionContent);
}

// Build arrow bullet list items from copy section
function buildArrowList(lines, accentColor) {
  return lines
    .filter((line) => line.length > 10)
    .map((line) => {
      // Detect uppercase emphasis tokens like "APRÈS", "TOI"
      const highlighted = escHtml(line).replace(
        /\b([A-ZÀÂÄÉÈÊËÎÏÔÙÛÜÇ]{3,})\b/g,
        `<span style="color:var(--foreground);font-weight:500;">$1</span>`
      );
      return `<p class="body-text" style="font-size:24px;">→ ${highlighted}</p>`;
    })
    .join("\n      ");
}

// Build grid of format cards (for SIGNAL 02 pattern)
function buildFormatGrid(lines, slideColorVar) {
  const formatIcons = ["📱", "🎬", "✍️", "📧", "🎙️", "📰"];
  const formatColors = [
    "var(--primary)", "var(--secondary)", "var(--accent)", "var(--foreground)"
  ];

  return `
    <div style="display:grid;grid-template-columns:1fr 1fr;gap:16px;max-width:600px;margin-top:50px;">
      ${lines.slice(0, 4).map((line, idx) => `
      <div style="border:1px solid rgba(255,255,255,0.06);border-radius:12px;padding:24px;text-align:center;">
        <div style="font-size:28px;margin-bottom:8px;">${formatIcons[idx] || "✦"}</div>
        <div class="mono" style="font-size:13px;color:${formatColors[idx % formatColors.length]};">${escHtml(line)}</div>
      </div>`).join("")}
    </div>`.trim();
}

// Build comparison rows (for SIGNAL 03 pattern — hook scoring)
function buildComparisonRows(lines, primaryColorVar) {
  const variants = lines.filter((l) => l.length > 3).slice(0, 4);
  const winnerIndex = 1; // Second variant wins (middle score, best result)

  return `
    <div style="margin-top:50px;display:flex;flex-direction:column;gap:12px;max-width:650px;">
      ${variants.map((line, idx) => {
        const isWinner = idx === winnerIndex;
        const score = ["6.2%", "9.1% ★", "5.8%", "7.4%"][idx] || `${(5 + idx * 1.5).toFixed(1)}%`;
        if (isWinner) {
          return `
      <div style="border:2px solid var(--primary);border-radius:8px;padding:20px 24px;display:flex;justify-content:space-between;align-items:center;box-shadow:0 0 20px rgba(204,255,0,0.15);">
        <span style="font-size:18px;color:var(--foreground);font-weight:500;">${escHtml(line)}</span>
        <span class="mono" style="font-size:14px;color:var(--primary);font-weight:500;">${score}</span>
      </div>`;
        }
        return `
      <div style="border:1px solid rgba(255,255,255,0.06);border-radius:8px;padding:20px 24px;display:flex;justify-content:space-between;align-items:center;">
        <span style="font-size:18px;color:var(--muted);">${escHtml(line)}</span>
        <span class="mono" style="font-size:14px;color:var(--muted);">${score}</span>
      </div>`;
      }).join("")}
    </div>`.trim();
}

function buildSignalSlide(slideEntry, copySection, slideNumber, totalSlides) {
  const signalNumber = parseSignalNumber(slideEntry.role);
  const accentColor = signalColor(signalNumber);
  const accentColorStyle = signalColorClass(signalNumber);
  const signalNumStr = String(signalNumber).padStart(2, "0");
  const lines = extractTextLines(copySection);
  const headline = escHtml(slideEntry.headline || lines[0] || "");
  const contentLines = lines.slice(1);
  const punchline = extractPunchline(copySection);
  const chrome = buildSlideChrome(slideNumber, totalSlides, false, false);

  // Detect content pattern by signal number
  let contentHtml = "";

  if (signalNumber === 2) {
    // Format grid
    contentHtml = buildFormatGrid(contentLines, accentColor);
    const reachLine = contentLines.find((l) => l.includes("portée") || l.includes("reach"));
    if (reachLine) {
      const highlighted = escHtml(reachLine).replace(
        /\b(\d+x[^\s.]*)/g,
        `<span style="color:var(--foreground);font-weight:600;">$1</span>`
      );
      contentHtml += `\n    <p style="font-size:22px;color:var(--muted);margin-top:40px;">${highlighted}</p>`;
    }
  } else if (signalNumber === 3) {
    // Comparison rows
    const hookLines = contentLines.filter((l) => l.length > 4 && !l.includes("→"));
    const comparisonLines = hookLines.length >= 2
      ? hookLines
      : ["Hook variante A", "Hook variante B", "Hook variante C"];
    contentHtml = buildComparisonRows(comparisonLines, accentColor);
    contentHtml += `\n    <p style="font-size:22px;color:var(--foreground);margin-top:50px;font-weight:500;">${escHtml(punchline)}</p>`;
  } else {
    // Default: arrow bullet list (SIGNAL 01 and 04)
    contentHtml = `<div style="margin-top:50px;display:flex;flex-direction:column;gap:20px;">${buildArrowList(contentLines, accentColor)}</div>`;

    // SIGNAL 04 special: big closing statement
    if (signalNumber === 4) {
      const closingLine = contentLines[contentLines.length - 1] || "";
      contentHtml += `\n    <p style="font-size:44px;margin-top:60px;font-family:var(--font-display);font-weight:700;${accentColorStyle};" class="text-glow">${escHtml(closingLine)}</p>`;
    }
  }

  const orbHtml = signalNumber === 4
    ? `<div class="orb orb-secondary" style="width:500px;height:500px;bottom:-100px;right:-100px;opacity:0.08;"></div>`
    : "";

  return `
<!-- SLIDE ${slideNumber} — SIGNAL ${signalNumStr} -->
<div class="slide" id="slide-${slideNumber}">
  <div class="signal-number" style="${accentColorStyle};font-family:var(--font-mono);font-size:120px;font-weight:500;line-height:1;opacity:0.15;position:absolute;top:80px;left:80px;">${signalNumStr}</div>
  ${orbHtml}
  ${chrome}
  <div style="position:relative;z-index:1;">
    <div class="mono" style="font-size:14px;letter-spacing:0.15em;text-transform:uppercase;margin-bottom:24px;${accentColorStyle};">Signal</div>
    <h2 style="font-size:48px;max-width:750px;">${headline}</h2>
    ${contentHtml}
  </div>
</div>`.trim();
}

// ---------------------------------------------------------------------------
// Layout template: ACTION
// ---------------------------------------------------------------------------

function buildActionSlide(slideEntry, copySection, slideNumber, totalSlides) {
  const lines = extractTextLines(copySection);
  const headline = escHtml(slideEntry.headline || lines[0] || "");
  const footerLine = escHtml(lines[lines.length - 1] || "");
  // Steps: everything between first and last line
  const stepLines = lines.slice(1, lines.length - 1);
  const chrome = buildSlideChrome(slideNumber, totalSlides, !isLastSlide(slideNumber, totalSlides), false);

  const stepsHtml = stepLines
    .map((line) => `<p style="font-size:24px;color:var(--foreground);line-height:1.5;">${escHtml(line)}</p>`)
    .join("\n      ");

  return `
<!-- SLIDE ${slideNumber} — ACTION -->
<div class="slide" id="slide-${slideNumber}" style="background:#111111;">
  ${chrome}
  <div style="position:relative;z-index:1;text-align:center;max-width:700px;margin:0 auto;">
    <div class="mono" style="font-size:14px;letter-spacing:0.15em;text-transform:uppercase;margin-bottom:32px;color:var(--primary);">Cette semaine</div>
    <h2 style="font-size:44px;">${headline}</h2>
    <div style="margin-top:50px;text-align:left;display:flex;flex-direction:column;gap:24px;">
      ${stepsHtml}
    </div>
    <p style="font-size:22px;margin-top:60px;color:var(--dark-gray);font-style:italic;">${footerLine}</p>
  </div>
</div>`.trim();
}

// ---------------------------------------------------------------------------
// Layout template: CTA
// ---------------------------------------------------------------------------

function buildCtaSlide(slideEntry, copySection, slideNumber, totalSlides) {
  const ctaUrl = escHtml(carousel.cta && carousel.cta.url ? carousel.cta.url : slideEntry.headline || "");
  const ctaTagline = escHtml(carousel.cta && carousel.cta.tagline ? carousel.cta.tagline : "");
  const lines = extractTextLines(copySection);
  const brandHeadline = escHtml(lines[0] || `${tokens.brandName} fait ça automatiquement.`);
  const chrome = buildSlideChrome(slideNumber, totalSlides, true, true);

  // Feature lines: all lines except first, last two (url + tagline)
  const featureLines = lines.filter((line) => {
    const lower = line.toLowerCase();
    return !lower.includes(ctaUrl.toLowerCase()) && line !== lines[0];
  });

  const featuresHtml = featureLines
    .map((line) => `<span class="body-text" style="font-size:22px;">${escHtml(line)}</span>`)
    .join("\n      ");

  return `
<!-- SLIDE ${slideNumber} — CTA -->
<div class="slide" id="slide-${slideNumber}">
  <div class="orb orb-primary" style="width:700px;height:700px;top:50%;left:50%;transform:translate(-50%,-50%);opacity:0.06;"></div>
  ${chrome}
  <div style="position:relative;z-index:1;text-align:center;">
    <p style="font-family:var(--font-display);font-weight:700;font-size:36px;color:var(--foreground);margin-bottom:50px;">${brandHeadline}</p>
    <div style="display:flex;flex-direction:column;gap:16px;align-items:center;">
      ${featuresHtml}
    </div>
    <div style="margin-top:70px;">
      <span class="mono text-glow" style="font-size:56px;font-weight:500;color:var(--primary);">${ctaUrl}</span>
    </div>
    ${ctaTagline ? `<p style="font-size:20px;color:var(--dark-gray);margin-top:24px;">${ctaTagline}</p>` : ""}
  </div>
</div>`.trim();
}

// ---------------------------------------------------------------------------
// Slide dispatcher
// ---------------------------------------------------------------------------

function buildSlide(slideEntry, copySection, totalSlides) {
  const role = (slideEntry.role || "").toUpperCase();
  const slideNumber = slideEntry.slide;
  const sectionContent = copySection || "";

  if (role === "HOOK" || role === "TITLE") {
    return buildHookSlide(slideEntry, sectionContent, slideNumber, totalSlides);
  }
  if (role === "DATA") {
    return buildDataSlide(slideEntry, sectionContent, slideNumber, totalSlides);
  }
  if (role === "PAIN") {
    return buildPainSlide(slideEntry, sectionContent, slideNumber, totalSlides);
  }
  if (role === "SHIFT") {
    return buildShiftSlide(slideEntry, sectionContent, slideNumber, totalSlides);
  }
  if (role.startsWith("SIGNAL")) {
    return buildSignalSlide(slideEntry, sectionContent, slideNumber, totalSlides);
  }
  if (role === "ACTION") {
    return buildActionSlide(slideEntry, sectionContent, slideNumber, totalSlides);
  }
  if (role === "CTA") {
    return buildCtaSlide(slideEntry, sectionContent, slideNumber, totalSlides);
  }

  // Fallback: generic text slide
  const lines = extractTextLines(sectionContent);
  const chrome = buildSlideChrome(slideNumber, totalSlides, isLastSlide(slideNumber, totalSlides), false);
  const bodyHtml = lines.map((l) => `<p class="body-text" style="font-size:28px;">${escHtml(l)}</p>`).join("\n    ");
  return `
<!-- SLIDE ${slideNumber} — ${escHtml(slideEntry.role)} -->
<div class="slide" id="slide-${slideNumber}">
  ${chrome}
  <div style="position:relative;z-index:1;">
    ${bodyHtml}
  </div>
</div>`.trim();
}

// ---------------------------------------------------------------------------
// Inline CSS builder
// ---------------------------------------------------------------------------

function buildInlineCss(tok) {
  return `
:root {
  --primary: ${tok.primaryHex};
  --secondary: ${tok.secondaryHex};
  --accent: ${tok.accentHex};
  --bg: ${tok.bgHex};
  --surface: ${tok.surfaceHex};
  --foreground: ${tok.foregroundHex};
  --muted: ${tok.mutedHex};
  --dark-gray: ${tok.darkGrayHex};
  --font-display: '${tok.displayFamily}', sans-serif;
  --font-body: '${tok.bodyFamily}', system-ui, sans-serif;
  --font-mono: '${tok.monoFamily}', monospace;
}

* { margin: 0; padding: 0; box-sizing: border-box; }

body {
  background: #000;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 40px;
  padding: 40px;
  font-family: var(--font-body);
}

.slide {
  width: 1080px;
  height: 1350px;
  background: var(--bg);
  position: relative;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  justify-content: center;
  padding: 80px;
  color: var(--foreground);
}

/* 54px grid overlay */
.slide::before {
  content: '';
  position: absolute;
  inset: 0;
  background-image:
    linear-gradient(rgba(255,255,255,0.015) 1px, transparent 1px),
    linear-gradient(90deg, rgba(255,255,255,0.015) 1px, transparent 1px);
  background-size: 54px 54px;
  pointer-events: none;
}

.slide-number {
  position: absolute;
  top: 60px;
  right: 80px;
  font-family: var(--font-mono);
  font-size: 14px;
  color: var(--dark-gray);
  letter-spacing: 0.1em;
}

.logo-watermark {
  position: absolute;
  bottom: 60px;
  right: 80px;
  font-family: var(--font-display);
  font-weight: 700;
  font-size: 16px;
  color: var(--primary);
  opacity: 0.4;
  letter-spacing: 0.05em;
}

.swipe-indicator {
  position: absolute;
  bottom: 60px;
  left: 80px;
  font-family: var(--font-mono);
  font-size: 12px;
  color: var(--dark-gray);
  letter-spacing: 0.1em;
  text-transform: uppercase;
}

h1 {
  font-family: var(--font-display);
  font-weight: 700;
  line-height: 1.08;
  letter-spacing: -0.02em;
}

h2 {
  font-family: var(--font-display);
  font-weight: 700;
  line-height: 1.15;
  letter-spacing: -0.01em;
}

.body-text {
  font-family: var(--font-body);
  font-weight: 400;
  line-height: 1.6;
  color: var(--muted);
}

.mono {
  font-family: var(--font-mono);
}

.big-number {
  font-family: var(--font-mono);
  font-weight: 500;
  line-height: 1;
}

/* Orb effects */
.orb {
  position: absolute;
  border-radius: 50%;
  filter: blur(100px);
  pointer-events: none;
}
.orb-primary {
  background: var(--primary);
  opacity: 0.08;
}
.orb-secondary {
  background: var(--secondary);
  opacity: 0.06;
}

.text-glow {
  text-shadow: 0 0 40px color-mix(in srgb, var(--primary) 30%, transparent);
}
`.trim();
}

// ---------------------------------------------------------------------------
// Full HTML document builder
// ---------------------------------------------------------------------------

function buildHtmlDocument(carouselData, brandData, tok, slidesHtml) {
  const title = escHtml(carouselData.title || `${brandData.name || "Brand"} Carousel`);
  const fontsLinkTag = googleFontsUrl
    ? `<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="${googleFontsUrl}" rel="stylesheet">`
    : "<!-- No Google Fonts configured -->";

  const inlineCss = buildInlineCss(tok);
  const createdAt = carouselData.createdAt || new Date().toISOString().slice(0, 10);
  const format = carouselData.format || "1080x1350";
  const slideCount = carouselData.slides || carouselData.structure.length;

  return `<!DOCTYPE html>
<html lang="${carouselData.language || "en"}">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
${fontsLinkTag}
<title>${title}</title>
<!-- Generated by generate-carousel-html.mjs | Brand: ${escHtml(tok.brandName)} | Format: ${escHtml(format)} | Slides: ${slideCount} | Date: ${createdAt} -->
<style>
${inlineCss}
</style>
</head>
<body>

${slidesHtml}

</body>
</html>`;
}

// ---------------------------------------------------------------------------
// Main generation
// ---------------------------------------------------------------------------

const structure = carousel.structure || [];
const totalSlides = carousel.slides || structure.length;

if (structure.length === 0) {
  console.error("Error: carousel.json has no slides in 'structure' array.");
  process.exit(1);
}

const slidesHtml = structure
  .map((slideEntry) => {
    const copySection = copySections[slideEntry.slide] || "";
    return buildSlide(slideEntry, copySection, totalSlides);
  })
  .join("\n\n");

const htmlDocument = buildHtmlDocument(carousel, brand, tokens, slidesHtml);

// ---------------------------------------------------------------------------
// Output
// ---------------------------------------------------------------------------

const outputPath = args.output || null;

if (outputPath) {
  const resolvedOutput = path.resolve(outputPath);
  const outputDir = path.dirname(resolvedOutput);
  fs.mkdirSync(outputDir, { recursive: true });
  fs.writeFileSync(resolvedOutput, htmlDocument, "utf-8");
  console.log(`Generated: ${resolvedOutput} (${totalSlides} slides, ${structure.length} templates rendered)`);
} else {
  process.stdout.write(htmlDocument);
}
