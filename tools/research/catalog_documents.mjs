import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';

export const projectRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../..');
export const registryPath = path.join(projectRoot, 'resources/research/nasa_technology_catalog.json');
export const documentPath = path.join(projectRoot, 'docs/NASA_TECHNOLOGY_CATALOG.md');
export const readRegistry = () => JSON.parse(fs.readFileSync(registryPath, 'utf8'));

export function renderCatalog(catalog) {
  const sources = new Map(catalog.sources.map(source => [source.id, source]));
  const cite = id => `[${id}](${sources.get(id).url})`;
  const displayDate = date => date ?? 'not confirmed';
  const list = values => values.join('; ');
  const countStatus = status => catalog.entries.filter(entry => entry.evidence_status === status).length;
  const lines = [
    '# NASA Technology Catalog', '',
    `Registry version: **${catalog.catalog_version}**. Evidence reviewed through **${catalog.reviewed_through}**.`, '',
    `**${catalog.entries.length} entries, ${catalog.categories.length} categories, ${catalog.sources.length} official sources.**`, '',
    'This is a research inventory, not an implementation plan, a clinical protocol or a list of equipment currently deployed on the Moon. Read the [Science Bible](SCIENCE_BIBLE.md) and [Scientific Gameplay Rules](SCIENTIFIC_GAMEPLAY_RULES.md) alongside it.', '',
    'The canonical structured records are in [the research registry](../resources/research/nasa_technology_catalog.json). The directory is excluded from Godot scanning with `.gdignore`; gameplay item Resources remain separate. No runtime code loads this registry.', '',
    'This document is rendered from the JSON. Regenerate with `node tools/research/catalog_documents.mjs --write`, then validate with `node tools/research/validate_science_catalog.mjs`. Default rendering mode is `--check` and never writes.', '',
    '## Reading the evidence', '',
    '| Status | Entries | Meaning |', '| --- | ---: | --- |',
    ...Object.entries(catalog.status_definitions).map(([status, definition]) => `| ${status} | ${countStatus(status)} | ${definition} |`), '',
    '`entry_kind` distinguishes hardware/system/procedure from research programs, risk references, standards and environmental references. The latter records are included for completeness; they are not all technologies or products.', '',
    'Every record has its own evidence status, actual test environment, Moon/Mars applicability, limitations, sources and proposed game use. Operational means documented operation or heritage in that stated setting; it does not guarantee present telemetry, uninterrupted service or qualification on another world.', '',
    'The three fields marked **Design proposal** are project interpretations, not NASA-qualified system recipes. Equipment lists are enabling interfaces, not complete bills of materials; dependency links are research IDs, not in-game items or automatic unlocks. Circular recovery chains require delivered startup reserves and an external energy source.', '',
    'No achieved numeric TRL is asserted in this edition. A null rating means no configuration-specific achieved rating was transcribed; it never means TRL 0. [NASA defines the readiness framework](https://www.nasa.gov/directorates/somd/space-communications-navigation-program/technology-readiness-levels/), but those definitions do not rate individual entries. Future non-null values require a level, assessment date, evidence source, configuration scope and test environment.', '',
    '## Coverage', '', '| Category | Entries |', '| --- | ---: |',
    ...catalog.categories.map(category => `| ${category.number}. ${category.name} | ${catalog.entries.filter(entry => entry.category_id === category.id).length} |`), '',
    '## Inventory', ''
  ];
  for (const category of catalog.categories) {
    lines.push(`## ${category.number}. ${category.name}`, '');
    for (const entry of catalog.entries.filter(item => item.category_id === category.id)) {
      const trl = entry.published_trl === null ? `Not assigned. ${entry.trl_note}` : `${entry.published_trl.level}; ${entry.published_trl.scope}; assessed ${entry.published_trl.assessed_on}; ${cite(entry.published_trl.source_id)}.`;
      lines.push(
        `### ${entry.id} - ${entry.official_name}`, '',
        `- **Kind / evidence:** ${entry.entry_kind} / ${entry.evidence_status}, reviewed ${entry.status_as_of}.`,
        `- **Actual function:** ${entry.actual_function}`,
        `- **Organization:** ${entry.source_organization}.`,
        `- **Official evidence:** ${entry.source_ids.map(cite).join(', ')}. Source publication/update dates appear in the source index and JSON source_dates.`,
        `- **Actual testing or operation:** ${entry.actual_testing_environment}`,
        `- **Published TRL:** ${trl}`,
        `- **Moon applicability:** ${entry.applicability.moon}`,
        `- **Mars applicability:** ${entry.applicability.mars}`,
        `- **Limitations / uncertainties:** ${list(entry.limitations_and_uncertainties)}`,
        `- **Design proposal - recommended game use:** ${entry.recommended_game_use}`,
        `- **Design proposal - supporting equipment:** ${list(entry.required_supporting_equipment)}.`,
        `- **Design proposal - dependencies:** ${entry.gameplay_dependencies.length ? entry.gameplay_dependencies.map(dependency => `${dependency.target_id}: ${dependency.relationship}`).join(' ') : 'No other catalog entry is a mandatory prerequisite; the equipment above still applies.'}`, ''
      );
    }
  }
  lines.push('## Evidence issues and status reconciliations', '', '| ID | Evidence issue | Handling | Sources |', '| --- | --- | --- | --- |');
  for (const issue of catalog.known_evidence_issues) lines.push(`| ${issue.id} | ${issue.issue} | ${issue.resolution} | ${issue.source_ids.map(cite).join(', ')} |`);
  lines.push('', '## Official source index', '',
    'All sources were accessed on the review date. A missing date is an acknowledged evidence gap, not a fabricated publication date. Dates belong to the source, while an entry may describe an earlier event. Hub pages can mix future plans with historical results; linked specific reports take precedence for status. The twelve requested starting pages are retained, including context-only hubs.', '',
    '| Source ID / official reference | Organization | Publication | Update | Date/context note |',
    '| --- | --- | --- | --- | --- |');
  for (const source of catalog.sources) lines.push(`| [${source.id} - ${source.title}](${source.url}) | ${source.organization} | ${displayDate(source.published_on)} | ${displayDate(source.updated_on)} | ${source.date_note} |`);
  lines.push('', '## Maintenance contract', '',
    'Never repurpose or recycle a stable entry ID. Update evidence with a dated rationale; retire a record explicitly rather than silently assigning its ID to different hardware. Preserve source publication dates separately from page updates. Search for newer primary milestone evidence before changing development status; an expired target year or a repository project-end field is insufficient.', '',
    'This edition is a documented public-source baseline as of November 15, 2026, not an exhaustive NASA procurement database, live program-status service or medical standard. Missing dates, incomplete qualification evidence and unconfirmed current service remain explicit limitations. No system implementation, asset generation, audio or Phase 0.8B work is authorized by this catalog.', ''
  );
  return lines.join('\n');
}

if (process.argv[1] && import.meta.url === pathToFileURL(path.resolve(process.argv[1])).href) {
  const mode = process.argv[2] ?? '--check';
  if (!['--check', '--write'].includes(mode) || process.argv.length > 3) {
    console.error('Usage: node tools/research/catalog_documents.mjs [--check|--write]');
    process.exitCode = 1;
  } else {
    const rendered = renderCatalog(readRegistry());
    if (mode === '--write') {
      fs.writeFileSync(documentPath, rendered, 'utf8');
      console.log('Rendered docs/NASA_TECHNOLOGY_CATALOG.md');
    } else if (!fs.existsSync(documentPath) || fs.readFileSync(documentPath, 'utf8') !== rendered) {
      console.error('Catalog Markdown differs from the canonical JSON. Run with --write after reviewing edits.');
      process.exitCode = 1;
    } else console.log('Catalog Markdown matches the canonical JSON.');
  }
}
