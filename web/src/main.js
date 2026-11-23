import '@google/model-viewer';
import './style.css';

const viewer = document.querySelector('#knight-viewer');
const statusLabel = document.querySelector('#model-status');
const statusDot = document.querySelector('#model-status-dot');
const progressBar = document.querySelector('.model-progress span');
const spinButton = document.querySelector('#spin-toggle');
const resetButton = document.querySelector('#reset-view');

function setStatus(label, state = 'loading') {
  statusLabel.textContent = label;
  statusDot.classList.toggle('is-ready', state === 'ready');
  statusDot.classList.toggle('is-error', state === 'error');
}

viewer.addEventListener('progress', (event) => {
  const progress = Math.round((event.detail?.totalProgress ?? 0) * 100);
  progressBar.style.width = `${progress}%`;
});

viewer.addEventListener('load', () => {
  setStatus('MODEL READY', 'ready');
  progressBar.style.width = '100%';
  window.setTimeout(() => {
    progressBar.parentElement?.classList.add('is-complete');
  }, 500);
});

viewer.addEventListener('error', () => {
  setStatus('MODEL UNAVAILABLE', 'error');
  document.querySelector('.viewer-instruction').textContent = 'THE MODEL COULD NOT BE LOADED';
});

spinButton.addEventListener('click', () => {
  const shouldSpin = !viewer.hasAttribute('auto-rotate');
  viewer.toggleAttribute('auto-rotate', shouldSpin);
  spinButton.setAttribute('aria-pressed', String(shouldSpin));
  spinButton.querySelector('span').textContent = shouldSpin ? 'PAUSE ROTATION' : 'START ROTATION';
});

resetButton.addEventListener('click', () => {
  viewer.cameraOrbit = '28deg 76deg 4.1m';
  viewer.cameraTarget = 'auto auto auto';
  viewer.jumpCameraToGoal();
});
