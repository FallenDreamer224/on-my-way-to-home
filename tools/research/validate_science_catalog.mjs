import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import { pathToFileURL } from 'node:url';
import { projectRoot, readRegistry, renderCatalog, documentPath } from './catalog_documents.mjs';

const statuses = ['operational', 'demonstrated', 'in_development', 'research'];
const kinds = ['hardware', 'system', 'procedure', 'research_program', 'risk_reference', 'environment_reference', 'standard'];
const text = value => typeof value === 'string' && value.trim().length > 0;
const isDate = value => typeof value === 'string' && /^\d{4}-\d{2}-\d{2}$/.test(value) &&
  Number.isFinite(Date.parse(value)) && new Date(value).toISOString().slice(0, 10) === value;
const isOfficial = value => {
  try {
    const url = new URL(value);
    return url.protocol === 'https:' && (url.hostname === 'nasa.gov' || url.hostname.endsWith('.nasa.gov'));
  } catch { return false; }
};

export function validateRegistry(catalog) {
  const errors = [], warnings = [];
  const check = (condition, message) => { if (!condition) errors.push(message); };
  if (!catalog || typeof catalog !== 'object') return { errors: ['Registry must be an object.'], warnings };
  check(/^\d+\.\d+\.\d+$/.test(catalog.schema_version), 'Invalid schema version.');
  check(/^\d+\.\d+\.\d+$/.test(catalog.catalog_version), 'Invalid catalog version.');
  check(isDate(catalog.reviewed_through), 'Invalid evidence cutoff.');
  for (const key of ['title', 'scope']) check(text(catalog[key]), `Missing ${key}.`);
  for (const key of ['evidence_policy', 'date_policy', 'trl_policy', 'design_policy', 'applicability_policy', 'dependency_policy'])
    check(text(catalog.methodology?.[key]), `Missing methodology.${key}.`);
  for (const status of statuses) check(text(catalog.status_definitions?.[status]), `Missing status definition: ${status}.`);
  for (const key of ['categories', 'sources', 'entries', 'known_evidence_issues'])
    check(Array.isArray(catalog[key]) && catalog[key].length > 0, `Missing/empty array: ${key}.`);
  if (errors.length) return { errors, warnings };
  const unique = (records, name) => {
    const ids = records.map(record => record?.id);
    check(ids.every(text) && new Set(ids).size === ids.length, `${name}: missing or duplicate IDs.`);
    return new Map(records.map(record => [record.id, record]));
  };
  const categories = unique(catalog.categories, 'categories');
  const sources = unique(catalog.sources, 'sources');
  const entries = unique(catalog.entries, 'entries');
  for (const id of ['SRC-MOONBASE', 'SRC-ECLSS', 'SRC-JSC', 'SRC-SUITS', 'SRC-ROVERS', 'SRC-SURFACE', 'SRC-HAZARDS', 'SRC-RISKS', 'SRC-PLANTS', 'SRC-CHAPEA-ABOUT', 'SRC-MOXIE', 'SRC-TRL'])
    check(sources.has(id), `Requested starting source missing: ${id}.`);
  unique(catalog.known_evidence_issues, 'evidence issues');
  check(categories.size === 16, 'Exactly 16 research categories are required.');
  check(catalog.categories.every((category, index) => category.number === index + 1 && text(category.name)), 'Category numbering/names are invalid.');
  const date = (value, label, nullable = false) => {
    if (nullable && value === null) return;
    check(isDate(value), `${label}: expected ISO date${nullable ? ' or null' : ''}.`);
    if (isDate(value)) check(value <= catalog.reviewed_through, `${label}: date exceeds evidence cutoff.`);
  };
  for (const source of catalog.sources) {
    check(/^SRC-[A-Z0-9-]+$/.test(source.id), `${source.id}: invalid source ID.`);
    for (const key of ['title', 'organization', 'date_note']) check(text(source[key]), `${source.id}: missing ${key}.`);
    check(isOfficial(source.url), `${source.id}: reference must be an official HTTPS NASA domain.`);
    date(source.published_on, `${source.id}.published_on`, true);
    date(source.updated_on, `${source.id}.updated_on`, true);
    date(source.accessed_on, `${source.id}.accessed_on`);
    if (source.published_on === null && source.updated_on === null) warnings.push(`${source.id}: source publication/update day is unconfirmed.`);
    if (source.published_on && source.updated_on && source.updated_on < source.published_on)
      warnings.push(`${source.id}: displayed update precedes publication; preserve the documented discrepancy.`);
  }
  for (const entry of catalog.entries) {
    const label = entry.id;
    check(/^NASA-[A-Z0-9-]+$/.test(label), `${label}: invalid stable research ID.`);
    for (const key of ['official_name', 'actual_function', 'source_organization', 'actual_testing_environment', 'trl_note', 'recommended_game_use'])
      check(text(entry[key]), `${label}: missing ${key}.`);
    check(categories.has(entry.category_id), `${label}: unknown category.`);
    check(kinds.includes(entry.entry_kind), `${label}: invalid entry kind.`);
    check(statuses.includes(entry.evidence_status), `${label}: invalid evidence status.`);
    date(entry.status_as_of, `${label}.status_as_of`);
    check(entry.status_as_of === catalog.reviewed_through, `${label}: review date differs from catalog cutoff.`);
    check(entry.design_fields_are_proposals === true, `${label}: design/evidence separation must be explicit.`);
    for (const body of ['moon', 'mars']) check(text(entry.applicability?.[body]), `${label}: missing ${body} applicability.`);
    for (const key of ['limitations_and_uncertainties', 'required_supporting_equipment', 'source_ids'])
      check(Array.isArray(entry[key]) && entry[key].length > 0 && entry[key].every(text), `${label}: missing/invalid ${key}.`);
    const refs = Array.isArray(entry.source_ids) ? entry.source_ids : [];
    check(new Set(refs).size === refs.length, `${label}: duplicate evidence source.`);
    for (const ref of refs) check(sources.has(ref), `${label}: unresolved source ${ref}.`);
    const primary = sources.get(refs[0]);
    check(isOfficial(entry.official_reference_url) && entry.official_reference_url === primary?.url, `${label}: primary URL differs from source registry.`);
    check(entry.source_organization === primary?.organization, `${label}: primary organization differs from source registry.`);
    const expectedDates = refs.map(ref => ({ source_id: ref, published_on: sources.get(ref)?.published_on, updated_on: sources.get(ref)?.updated_on }));
    check(JSON.stringify(entry.source_dates) === JSON.stringify(expectedDates), `${label}: source date copies differ from canonical evidence.`);
    check(Array.isArray(entry.gameplay_dependencies), `${label}: missing dependency list.`);
    for (const dependency of entry.gameplay_dependencies ?? []) {
      check(entries.has(dependency.target_id), `${label}: unresolved dependency ${dependency.target_id}.`);
      check(dependency.target_id !== label, `${label}: self dependency.`);
      check(text(dependency.relationship), `${label}: dependency lacks a relationship.`);
    }
    if (entry.published_trl !== null) {
      const trl = entry.published_trl;
      check(trl && Number.isInteger(trl.level) && trl.level >= 1 && trl.level <= 9, `${label}: invalid TRL; unknown must be null.`);
      check(text(trl?.scope) && text(trl?.environment) && text(trl?.evidence_locator), `${label}: numeric TRL needs scoped environment and exact evidence locator.`);
      check(refs.includes(trl?.source_id), `${label}: numeric TRL needs a cited primary source.`);
      date(trl?.assessed_on, `${label}.published_trl.assessed_on`);
    }
  }
  for (const category of catalog.categories)
    check(catalog.entries.some(entry => entry.category_id === category.id), `${category.id}: category has no coverage.`);
  for (const issue of catalog.known_evidence_issues) {
    check(text(issue.issue) && text(issue.resolution), `${issue.id}: issue and handling are required.`);
    check(Array.isArray(issue.source_ids) && issue.source_ids.length > 0 && issue.source_ids.every(id => sources.has(id)), `${issue.id}: invalid sources.`);
  }
  const trlCount = catalog.entries.filter(entry => entry.published_trl === null).length;
  warnings.push(`${trlCount} entries have null TRLs: no achieved numeric rating is asserted, or a hardware TRL is inapplicable.`);
  return { errors, warnings };
}

export function validateDocuments(catalog) {
  const errors = [];
  const check = (condition, message) => { if (!condition) errors.push(message); };
  const documents = ['docs/SCIENCE_BIBLE.md', 'docs/NASA_TECHNOLOGY_CATALOG.md', 'docs/SCIENTIFIC_GAMEPLAY_RULES.md', 'docs/phase_0_8R_report.md', 'AGENTS.md'];
  const ids = new Set(catalog.entries.map(entry => entry.id));
  for (const name of documents) {
    const filename = path.join(projectRoot, name);
    if (!fs.existsSync(filename)) { errors.push(`Missing ${name}.`); continue; }
    const content = fs.readFileSync(filename, 'utf8');
    check(!/\b(?:TODO|TBD|FIXME)\b/.test(content), `${name}: unfinished placeholder.`);
    for (const id of new Set(content.match(/\bNASA-[A-Z0-9]+(?:-[A-Z0-9]+)*\b/g) ?? []))
      check(ids.has(id), `${name}: unknown research ID ${id}.`);
    for (const match of content.matchAll(/\[[^\]\n]+\]\(([^)]+)\)/g)) {
      const target = match[1];
      if (/^https?:|^#/.test(target)) continue;
      const resolved = path.resolve(path.dirname(filename), decodeURIComponent(target.split('#')[0]));
      check(resolved.startsWith(projectRoot + path.sep) && fs.existsSync(resolved), `${name}: broken/outside-project local link ${target}.`);
    }
    if (name === 'docs/SCIENCE_BIBLE.md' || name === 'docs/SCIENTIFIC_GAMEPLAY_RULES.md') {
      check(content.includes(`Science baseline version: **${catalog.catalog_version}**`), `${name}: version drift.`);
      check(content.includes(`Evidence cutoff: **${catalog.reviewed_through}**`), `${name}: cutoff drift.`);
    }
  }
  check(fs.existsSync(documentPath) && fs.readFileSync(documentPath, 'utf8') === renderCatalog(catalog), 'Generated catalog differs from JSON.');
  const reportPath = path.join(projectRoot, 'docs/phase_0_8R_report.md');
  const dependencyCount = catalog.entries.reduce((sum, entry) => sum + entry.gameplay_dependencies.length, 0);
  const totals = `Registry totals: **${catalog.entries.length} entries; ${catalog.sources.length} sources; ${catalog.categories.length} categories; ${dependencyCount} dependency links**.`;
  check(fs.existsSync(reportPath) && fs.readFileSync(reportPath, 'utf8').includes(totals), 'Phase report totals differ from the registry.');
  check(fs.existsSync(path.join(projectRoot, 'resources/research/.gdignore')), 'Research registry must remain outside Godot scanning.');
  const instructions = fs.readFileSync(path.join(projectRoot, 'AGENTS.md'), 'utf8');
  for (const name of ['SCIENCE_BIBLE.md', 'NASA_TECHNOLOGY_CATALOG.md', 'SCIENTIFIC_GAMEPLAY_RULES.md', 'resources/research/nasa_technology_catalog.json'])
    check(instructions.includes(name), `AGENTS.md lacks mandatory research reference ${name}.`);
  return errors;
}

export function runSelfTests(catalog) {
  assert.deepEqual(validateRegistry(catalog).errors, [], 'Baseline must be valid.');
  const cases = [
    ['duplicate ID', copy => copy.entries.push(structuredClone(copy.entries[0]))],
    ['missing actual environment', copy => delete copy.entries[0].actual_testing_environment],
    ['unresolved dependency', copy => copy.entries[0].gameplay_dependencies.push({ target_id: 'NASA-MISSING', relationship: 'Invalid.' })],
    ['unofficial source', copy => { copy.sources[0].url = 'https://nasa.gov.example.org/'; }],
    ['future evidence date', copy => { copy.sources[0].published_on = '2027-01-01'; }],
    ['invalid calendar date', copy => { copy.sources[0].published_on = '2026-02-30'; }],
    ['fabricated TRL without evidence', copy => { copy.entries[0].published_trl = { level: 9 }; }],
    ['inconsistent source dates', copy => { copy.entries[0].source_dates[0].updated_on = '2000-01-01'; }],
    ['missing limitation', copy => { copy.entries[0].limitations_and_uncertainties = []; }],
    ['evidence/design conflation', copy => { copy.entries[0].design_fields_are_proposals = false; }],
    ['invalid status', copy => { copy.entries[0].evidence_status = 'lunar_deployed'; }],
    ['category omitted', copy => { copy.entries = copy.entries.filter(entry => entry.category_id !== 'medical'); }]
  ];
  for (const [name, mutate] of cases) {
    const copy = structuredClone(catalog);
    mutate(copy);
    assert(validateRegistry(copy).errors.length > 0, `Checker failed to reject ${name}.`);
  }
  return cases.length;
}

if (process.argv[1] && import.meta.url === pathToFileURL(path.resolve(process.argv[1])).href) {
  try {
    if (process.argv.length > 3 || (process.argv[2] && process.argv[2] !== '--self-test')) throw new Error('Usage: node tools/research/validate_science_catalog.mjs [--self-test]');
    const catalog = readRegistry();
    const result = validateRegistry(catalog);
    if (!result.errors.length) result.errors.push(...validateDocuments(catalog));
    if (process.argv[2] === '--self-test' && !result.errors.length)
      console.log(`PASS: ${runSelfTests(catalog)} invalid-fixture rejection checks.`);
    for (const warning of result.warnings) console.warn(`WARNING: ${warning}`);
    for (const error of result.errors) console.error(`ERROR: ${error}`);
    if (result.errors.length) process.exitCode = 1;
    else console.log(`PASS: valid JSON; ${catalog.entries.length} entries; ${catalog.sources.length} official sources; ${catalog.categories.length} categories; all source/dependency references and generated documentation agree. Errors: 0.`);
  } catch (error) {
    console.error(`ERROR: ${error.message}`);
    process.exitCode = 1;
  }
}
