import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../..');
const data = JSON.parse(fs.readFileSync(path.join(root, 'resources/data/habitat_layout.json'), 'utf8'));
const errors = [];
const check = (value, message) => { if (!value) errors.push(message); };
const point = value => Array.isArray(value) && value.length === 2 && value.every(Number.isInteger);
const ids = new Set(data.rooms.map(room => room.id));
check(ids.size === data.rooms.length && ids.size === 9, 'Nine unique room IDs required.');
check(point(data.exterior_entry_cell), 'Valid exterior entry required.');
check(Number.isInteger(data.default_room_zoom) && data.default_room_zoom >= 1 && data.default_room_zoom <= 3, 'Room overview zoom must be an integer from 1 to 3.');
check(Number.isFinite(data.cycle_presentation_seconds) && data.cycle_presentation_seconds > 0, 'Cycle presentation duration must be positive.');
const expected = ['main','airlock','equipment','suits','dust','sleep','galley','hygiene','greenhouse','eclss','water','power','medical','exercise','operations','science','cargo','shelter'];
const seen = new Set();
let totalFloor = 0;
for (const room of data.rooms) {
  check(/^[a-z_]+$/.test(room.id), `Invalid stable room ID ${room.id}.`);
  check(room.pressure_domain === (room.id === 'crew_airlock' ? 'airlock' : 'habitat'), `${room.id}: unexpected pressure domain.`);
  check(point(room.size) && room.size.every(value => value >= 5 && value <= 9), `${room.id}: invalid compact room size.`);
  const inside = p => point(p) && p[0] >= 1 && p[1] >= 1 && p[0] < room.size[0]-1 && p[1] < room.size[1]-1;
  const obstacles = [...room.extra_blocked_cells, ...room.facilities.map(facility => facility.fixture)];
  check(obstacles.every(inside), `${room.id}: invalid fixture/wall position.`);
  const blocked = new Set(obstacles.map(p => p.join(',')));
  const available = p => inside(p) && !blocked.has(p.join(','));
  check(available(room.spawn) && available(room.companion_spawn), `${room.id}: unsafe arrival.`);
  check(room.spawn.join(',') !== room.companion_spawn.join(','), `${room.id}: overlapping arrival anchors.`);
  const actions = [...room.facilities, ...room.doors];
  check(new Set(actions.map(action => action.id)).size === actions.length, `${room.id}: duplicate action IDs.`);
  check(new Set(actions.map(action => action.point.join(','))).size === actions.length, `${room.id}: overlapping action points.`);
  for (const action of actions) check(available(action.point), `${room.id}/${action.id}: blocked action point.`);
  for (const facility of room.facilities) {
    check(expected.includes(facility.id) && !seen.has(facility.id), `Unknown/duplicate facility ${facility.id}.`);
    seen.add(facility.id);
  }
  for (const door of room.doors) {
    check(ids.has(door.destination) || ['outside','inspect','cycle','seal_outer'].includes(door.destination), `${room.id}/${door.id}: unknown target.`);
    check(door.destination !== room.id, `${room.id}/${door.id}: self-link.`);
    if (door.destination === 'outside') check(room.id === 'crew_airlock', 'Only crew airlock may reach exterior.');
    if (door.destination === 'crew_airlock') check(room.id === 'equipment_lock', 'Only equipment lock may reach inner crew boundary.');
    if (room.id === 'crew_airlock' && ids.has(door.destination)) check(door.destination === 'equipment_lock', 'Crew airlock must pass through equipment lock.');
  }
  const queue = [room.spawn], reached = new Set([room.spawn.join(',')]);
  for (let head=0; head<queue.length; head++) for (const [dx,dy] of [[1,0],[-1,0],[0,1],[0,-1]]) {
    const p = [queue[head][0]+dx,queue[head][1]+dy], key=p.join(',');
    if (available(p) && !reached.has(key)) { reached.add(key); queue.push(p); }
  }
  totalFloor += reached.size;
  check(reached.size === (room.size[0]-2)*(room.size[1]-2)-blocked.size, `${room.id}: disconnected floor.`);
  for (const action of actions) check(reached.has(action.point.join(',')), `${room.id}: unreachable ${action.id}.`);
}
check(expected.every(id => seen.has(id)), 'Required facilities missing.');
const reachable = new Set(['equipment_lock']), pending = ['equipment_lock'];
for (let head=0; head<pending.length; head++) for (const door of data.rooms.find(room => room.id === pending[head]).doors) {
  if (ids.has(door.destination) && !reachable.has(door.destination)) { reachable.add(door.destination); pending.push(door.destination); }
}
check(reachable.size === ids.size, 'Room graph is disconnected.');
if (errors.length) { errors.forEach(error => console.error('ERROR: '+error)); process.exitCode=1; }
else console.log(`PASS: ${ids.size} compact rooms; all 16 requested facility groups (${expected.length} stations); ${totalFloor} connected floor cells; valid doors/arrival points.`);
