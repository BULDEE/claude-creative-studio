#!/usr/bin/env node
// Store a page description in the RAG SQLite database.
// Usage: echo '{"description":...}' | node embed-store.mjs --db <path> --source-file <name> --page-number <n> --image-path <path>

import Database from "better-sqlite3";

function parseArgs(args) {
  const result = {};
  for (let i = 0; i < args.length; i++) {
    if (args[i].startsWith("--") && i + 1 < args.length) {
      result[args[i].slice(2)] = args[i + 1];
      i++;
    }
  }
  return result;
}

const opts = parseArgs(process.argv.slice(2));
const dbPath = opts.db || "creative-rag.db";
const sourceFile = opts["source-file"];
const pageNumber = parseInt(opts["page-number"] || "0", 10);
const imagePath = opts["image-path"] || null;

if (!sourceFile) {
  console.error("Usage: echo '{...}' | node embed-store.mjs --db <path> --source-file <name> --page-number <n> [--image-path <path>]");
  process.exit(1);
}

// Read JSON from stdin
let input = "";
for await (const chunk of process.stdin) {
  input += chunk;
}

let data;
try {
  data = JSON.parse(input);
} catch {
  console.error(`Error: Invalid JSON on stdin`);
  process.exit(1);
}

const db = new Database(dbPath);
db.pragma("journal_mode = WAL");

// Create schema if needed
db.exec(`
  CREATE TABLE IF NOT EXISTS pages (
    id INTEGER PRIMARY KEY,
    source_file TEXT NOT NULL,
    page_number INTEGER NOT NULL,
    image_path TEXT,
    description TEXT NOT NULL,
    category TEXT,
    brand_name TEXT,
    methodology_step TEXT,
    hex_colors TEXT,
    fonts_detected TEXT,
    grid_ratios TEXT,
    materials TEXT,
    quality_notes TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(source_file, page_number)
  );

  CREATE VIRTUAL TABLE IF NOT EXISTS pages_fts USING fts5(
    description, category, brand_name, methodology_step,
    content=pages, content_rowid=id
  );

  CREATE TRIGGER IF NOT EXISTS pages_ai AFTER INSERT ON pages BEGIN
    INSERT INTO pages_fts(rowid, description, category, brand_name, methodology_step)
    VALUES (new.id, new.description, new.category, new.brand_name, new.methodology_step);
  END;

  CREATE TRIGGER IF NOT EXISTS pages_ad AFTER DELETE ON pages BEGIN
    INSERT INTO pages_fts(pages_fts, rowid, description, category, brand_name, methodology_step)
    VALUES ('delete', old.id, old.description, old.category, old.brand_name, old.methodology_step);
  END;

  CREATE TRIGGER IF NOT EXISTS pages_au AFTER UPDATE ON pages BEGIN
    INSERT INTO pages_fts(pages_fts, rowid, description, category, brand_name, methodology_step)
    VALUES ('delete', old.id, old.description, old.category, old.brand_name, old.methodology_step);
    INSERT INTO pages_fts(rowid, description, category, brand_name, methodology_step)
    VALUES (new.id, new.description, new.category, new.brand_name, new.methodology_step);
  END;
`);

const insert = db.prepare(`
  INSERT OR IGNORE INTO pages (source_file, page_number, image_path, description, category, brand_name, methodology_step, hex_colors, fonts_detected, grid_ratios, materials, quality_notes)
  VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
`);

const result = insert.run(
  sourceFile,
  pageNumber,
  imagePath,
  data.description || "",
  data.category || null,
  data.brand_name || null,
  data.methodology_step || null,
  JSON.stringify(data.hex_colors || []),
  JSON.stringify(data.fonts_detected || []),
  JSON.stringify(data.grid_ratios || []),
  JSON.stringify(data.materials || []),
  data.quality_notes || null
);

if (result.changes > 0) {
  console.log(`Stored: ${sourceFile} p.${pageNumber} [${data.category}]`);
} else {
  console.log(`Skipped (exists): ${sourceFile} p.${pageNumber}`);
}

db.close();
