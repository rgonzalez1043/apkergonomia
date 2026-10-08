import * as THREE from 'three';
import { OrbitControls } from 'three/addons/controls/OrbitControls.js';
import { GLTFLoader } from 'three/addons/loaders/GLTFLoader.js';

const params = new URLSearchParams(window.location.search);
const instanceId = params.get('instance') || 'body-map';
const debugZones = params.get('debug') === '1';
const statusElement = document.getElementById('status');

const scene = new THREE.Scene();
scene.background = new THREE.Color(params.get('theme') === 'dark' ? 0x142124 : 0xeef6f6);

const camera = new THREE.PerspectiveCamera(25, 1, 0.01, 20);
camera.position.set(0, 0.04, 4.25);

let renderer;
try {
  renderer = new THREE.WebGLRenderer({
    antialias: true,
    alpha: false,
    preserveDrawingBuffer: true,
    powerPreference: 'high-performance',
  });
} catch (error) {
  // three.js requires WebGL2; report it now instead of letting the app time out.
  setStatus('Este dispositivo no admite el visor 3D');
  emit('error', { message: 'webgl-unavailable' });
  throw error;
}
renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 2));
renderer.outputColorSpace = THREE.SRGBColorSpace;
renderer.toneMapping = THREE.ACESFilmicToneMapping;
renderer.toneMappingExposure = 1.08;
renderer.shadowMap.enabled = true;
renderer.shadowMap.type = THREE.PCFSoftShadowMap;
document.body.prepend(renderer.domElement);

const controls = new OrbitControls(camera, renderer.domElement);
controls.enableDamping = true;
controls.dampingFactor = 0.08;
controls.enablePan = false;
controls.enableZoom = true;
controls.minDistance = 3.25;
controls.maxDistance = 5.6;
controls.minPolarAngle = Math.PI * 0.31;
controls.maxPolarAngle = Math.PI * 0.69;
controls.target.set(0, 0, 0);

scene.add(new THREE.HemisphereLight(0xffffff, 0xa7b8bd, 2.1));

const keyLight = new THREE.DirectionalLight(0xffffff, 3.0);
keyLight.position.set(-2.4, 3.4, 3.5);
keyLight.castShadow = true;
keyLight.shadow.mapSize.set(1024, 1024);
scene.add(keyLight);

const rimLight = new THREE.DirectionalLight(0x8bd4cf, 2.0);
rimLight.position.set(2.6, 1.4, -3.2);
scene.add(rimLight);

const floor = new THREE.Mesh(
  new THREE.CircleGeometry(0.67, 64),
  new THREE.MeshBasicMaterial({
    color: 0xcbdada,
    transparent: true,
    opacity: 0.42,
    depthWrite: false,
  }),
);
floor.rotation.x = -Math.PI / 2;
floor.position.y = -1.015;
scene.add(floor);

const bodyRoot = new THREE.Group();
scene.add(bodyRoot);

const hitMaterial = new THREE.MeshBasicMaterial({
  color: 0xff424b,
  transparent: true,
  opacity: 0,
  depthTest: false,
  depthWrite: false,
});

const zoneMeshes = [];
const zonesByRegion = new Map();
let selectedRegion = params.get('selected') || null;
let hoveredRegion = null;
let modelReady = false;

// Anatomical left is positive X when the person is viewed from the front.
const L = 1;
const R = -1;

const zoneDefinitions = [
  { id: 'neck', p: [0, 0.705, 0], s: [0.115, 0.105, 0.145], surface: 'both' },

  { id: 'shoulderLeft', p: [0.19 * L, 0.575, 0], s: [0.17, 0.115, 0.19], surface: 'both' },
  { id: 'shoulderRight', p: [0.19 * R, 0.575, 0], s: [0.17, 0.115, 0.19], surface: 'both' },
  { id: 'armLeft', p: [0.315 * L, 0.365, 0], s: [0.115, 0.25, 0.145], surface: 'both', r: [0, 0, -0.12] },
  { id: 'armRight', p: [0.315 * R, 0.365, 0], s: [0.115, 0.25, 0.145], surface: 'both', r: [0, 0, 0.12] },
  { id: 'forearmLeft', p: [0.405 * L, 0.095, 0], s: [0.09, 0.235, 0.12], surface: 'both', r: [0, 0, -0.12] },
  { id: 'forearmRight', p: [0.405 * R, 0.095, 0], s: [0.09, 0.235, 0.12], surface: 'both', r: [0, 0, 0.12] },
  { id: 'handLeft', p: [0.445 * L, -0.105, 0], s: [0.085, 0.13, 0.09], surface: 'both' },
  { id: 'handRight', p: [0.445 * R, -0.105, 0], s: [0.085, 0.13, 0.09], surface: 'both' },

  { id: 'chestLeft', p: [0.105 * L, 0.43, 0.115], s: [0.145, 0.205, 0.105], surface: 'front' },
  { id: 'chestRight', p: [0.105 * R, 0.43, 0.115], s: [0.145, 0.205, 0.105], surface: 'front' },
  { id: 'abdomen', p: [0, 0.175, 0.105], s: [0.185, 0.24, 0.11], surface: 'front' },
  { id: 'upperBackLeft', p: [0.105 * L, 0.43, -0.115], s: [0.145, 0.205, 0.105], surface: 'back' },
  { id: 'upperBackRight', p: [0.105 * R, 0.43, -0.115], s: [0.145, 0.205, 0.105], surface: 'back' },
  { id: 'midBack', p: [0, 0.205, -0.12], s: [0.185, 0.18, 0.105], surface: 'back' },
  { id: 'lowerBack', p: [0, 0.015, -0.12], s: [0.18, 0.16, 0.105], surface: 'back' },
  { id: 'sacroiliac', p: [0, -0.115, -0.115], s: [0.17, 0.13, 0.105], surface: 'back' },

  { id: 'hipLeft', p: [0.145 * L, -0.185, 0], s: [0.15, 0.17, 0.18], surface: 'both' },
  { id: 'hipRight', p: [0.145 * R, -0.185, 0], s: [0.15, 0.17, 0.18], surface: 'both' },
  { id: 'thighLeft', p: [0.145 * L, -0.43, 0], s: [0.13, 0.285, 0.15], surface: 'both' },
  { id: 'thighRight', p: [0.145 * R, -0.43, 0], s: [0.13, 0.285, 0.15], surface: 'both' },
  { id: 'kneeLeft', p: [0.135 * L, -0.65, 0.015], s: [0.115, 0.13, 0.135], surface: 'both' },
  { id: 'kneeRight', p: [0.135 * R, -0.65, 0.015], s: [0.115, 0.13, 0.135], surface: 'both' },
  { id: 'calfLeft', p: [0.125 * L, -0.795, -0.015], s: [0.095, 0.20, 0.115], surface: 'both' },
  { id: 'calfRight', p: [0.125 * R, -0.795, -0.015], s: [0.095, 0.20, 0.115], surface: 'both' },
  { id: 'ankleLeft', p: [0.115 * L, -0.94, 0], s: [0.085, 0.095, 0.105], surface: 'both' },
  { id: 'ankleRight', p: [0.115 * R, -0.94, 0], s: [0.085, 0.095, 0.105], surface: 'both' },
];

function addHitZones() {
  for (const definition of zoneDefinitions) {
    const material = hitMaterial.clone();
    const mesh = new THREE.Mesh(new THREE.SphereGeometry(1, 24, 18), material);
    mesh.name = `pain-zone:${definition.id}`;
    mesh.position.fromArray(definition.p);
    mesh.scale.fromArray(definition.s);
    if (definition.r) mesh.rotation.set(...definition.r);
    mesh.userData.region = definition.id;
    mesh.userData.surface = definition.surface;
    mesh.renderOrder = 20;
    bodyRoot.add(mesh);
    zoneMeshes.push(mesh);
    zonesByRegion.set(definition.id, mesh);
  }
  updateZoneAppearance();
}

function updateZoneAppearance() {
  for (const mesh of zoneMeshes) {
    const isSelected = mesh.userData.region === selectedRegion;
    const isHovered = mesh.userData.region === hoveredRegion;
    mesh.material.opacity = debugZones ? 0.16 : isSelected ? 0.43 : isHovered ? 0.11 : 0;
    mesh.material.color.setHex(isSelected ? 0xff303b : isHovered ? 0xff747b : 0x2fb8ac);
    mesh.visible = debugZones || isSelected || isHovered || modelReady;
  }
}

function emit(type, data = {}) {
  const message = JSON.stringify({ channel: 'ergobody', instanceId, type, ...data });
  try {
    if (window.BodyMapBridge && window.BodyMapBridge.postMessage) {
      window.BodyMapBridge.postMessage(message);
    }
  } catch (_) {}
  try {
    if (window.parent && window.parent !== window) window.parent.postMessage(message, window.location.origin);
  } catch (_) {}
}

function setStatus(text) {
  statusElement.textContent = text || '';
  statusElement.hidden = !text;
}

const loader = new GLTFLoader();
loader.load(
  '../models/male_anatomy_figure.glb',
  (gltf) => {
    const model = gltf.scene;
    const bounds = new THREE.Box3().setFromObject(model);
    const size = bounds.getSize(new THREE.Vector3());
    const center = bounds.getCenter(new THREE.Vector3());
    const normalizedScale = 1.96 / size.y;
    model.scale.setScalar(normalizedScale);
    model.position.set(-center.x * normalizedScale, -center.y * normalizedScale, -center.z * normalizedScale);
    model.traverse((object) => {
      if (!object.isMesh) return;
      object.castShadow = true;
      object.receiveShadow = true;
      object.material = new THREE.MeshStandardMaterial({
        color: 0xa9c0bd,
        metalness: 0.08,
        roughness: 0.72,
        transparent: true,
        opacity: 0.98,
        side: THREE.DoubleSide,
      });
    });
    bodyRoot.add(model);
    modelReady = true;
    updateZoneAppearance();
    setStatus(null);
    for (const delay of [0, 250, 1000, 3000]) {
      window.setTimeout(
        () => emit('ready', { regionCount: zoneDefinitions.length }),
        delay,
      );
    }
  },
  undefined,
  (error) => {
    console.error('Body model failed to load', error);
    setStatus('No se pudo cargar el modelo 3D');
    emit('error', { message: 'model-load-failed' });
  },
);

addHitZones();

const raycaster = new THREE.Raycaster();
const pointer = new THREE.Vector2();
let pointerStart = null;

function surfaceIsVisible(mesh) {
  const surface = mesh.userData.surface;
  if (surface === 'both') return true;
  const viewingFront = camera.position.z >= 0;
  return viewingFront ? surface === 'front' : surface === 'back';
}

function hitsAt(clientX, clientY) {
  const rect = renderer.domElement.getBoundingClientRect();
  pointer.x = ((clientX - rect.left) / rect.width) * 2 - 1;
  pointer.y = -((clientY - rect.top) / rect.height) * 2 + 1;
  raycaster.setFromCamera(pointer, camera);
  return raycaster.intersectObjects(zoneMeshes, false).filter((hit) => surfaceIsVisible(hit.object));
}

renderer.domElement.addEventListener('pointerdown', (event) => {
  pointerStart = { x: event.clientX, y: event.clientY, at: performance.now() };
});

renderer.domElement.addEventListener('pointerup', (event) => {
  if (!pointerStart || !modelReady) return;
  const distance = Math.hypot(event.clientX - pointerStart.x, event.clientY - pointerStart.y);
  const elapsed = performance.now() - pointerStart.at;
  pointerStart = null;
  if (distance > 9 || elapsed > 650) return;
  const hits = hitsAt(event.clientX, event.clientY);
  if (!hits.length) return;
  const region = hits[0].object.userData.region;
  selectedRegion = region;
  hoveredRegion = null;
  updateZoneAppearance();
  emit('regionSelected', { region });
});

renderer.domElement.addEventListener('pointermove', (event) => {
  if (event.pointerType !== 'mouse' || !modelReady || event.buttons !== 0) return;
  const hit = hitsAt(event.clientX, event.clientY)[0];
  const next = hit ? hit.object.userData.region : null;
  if (next === hoveredRegion) return;
  hoveredRegion = next;
  renderer.domElement.style.cursor = next ? 'pointer' : 'grab';
  updateZoneAppearance();
});

renderer.domElement.addEventListener('pointerleave', () => {
  hoveredRegion = null;
  renderer.domElement.style.cursor = 'grab';
  updateZoneAppearance();
});

function setView(view) {
  const distance = THREE.MathUtils.clamp(camera.position.length(), 3.5, 4.6);
  const z = view === 'back' ? -distance : distance;
  camera.position.set(0, 0.04, z);
  camera.up.set(0, 1, 0);
  controls.target.set(0, 0, 0);
  controls.update();
}

setView(params.get('view') === 'back' ? 'back' : 'front');

function applyCommand(command) {
  if (!command || typeof command !== 'object') return;
  if (command.selectedRegion !== undefined) {
    selectedRegion = command.selectedRegion || null;
    updateZoneAppearance();
  }
  if (command.view === 'front' || command.view === 'back') setView(command.view);
  if (command.theme === 'dark') {
    scene.background.setHex(0x142124);
    document.body.style.background = '#142124';
  } else if (command.theme === 'light') {
    scene.background.setHex(0xeef6f6);
    document.body.style.background = '#eef6f6';
  }
}

window.bodyMapCommand = applyCommand;
window.addEventListener('message', (event) => {
  if (event.source !== window.parent || event.origin !== window.location.origin) return;
  let value = event.data;
  if (typeof value === 'string') {
    try { value = JSON.parse(value); } catch (_) { return; }
  }
  if (value && value.channel === 'ergobody-command' && value.instanceId === instanceId) {
    applyCommand(value);
  }
});

function resize() {
  const width = Math.max(1, window.innerWidth);
  const height = Math.max(1, window.innerHeight);
  camera.aspect = width / height;
  camera.updateProjectionMatrix();
  renderer.setSize(width, height, false);
}

window.addEventListener('resize', resize);
resize();

function animate() {
  controls.update();
  renderer.render(scene, camera);
  requestAnimationFrame(animate);
}

animate();
