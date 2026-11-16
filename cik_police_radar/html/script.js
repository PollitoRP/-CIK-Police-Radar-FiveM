// ==========================================================
//               CIK POLICE RADAR - CLIENT SCRIPT
// ==========================================================

let audioEnabled = true;
let speedUnit = 'KMH';
let fastLimit = 120;
let currentTheme = 'modern_hud';
let isAudioContextInit = false;
let audioCtx = null;

// Elementos DOM
const radarContainer = document.getElementById('radar-container');
const remoteContainer = document.getElementById('remote-container');

// Front elements
const frontCard = document.getElementById('front-radar-card');
const frontModeBadge = document.getElementById('front-mode-badge');
const frontLockBadge = document.getElementById('front-lock-badge');
const frontTargetSpeed = document.getElementById('front-target-speed');
const frontFastSpeed = document.getElementById('front-fast-speed');
const frontDirArrow = document.getElementById('front-dir-arrow');
const frontDirText = document.getElementById('front-dir-text');
const frontPlateText = document.getElementById('front-plate-text');
const frontModelText = document.getElementById('front-model-text');

// Rear elements
const rearCard = document.getElementById('rear-radar-card');
const rearModeBadge = document.getElementById('rear-mode-badge');
const rearLockBadge = document.getElementById('rear-lock-badge');
const rearTargetSpeed = document.getElementById('rear-target-speed');
const rearFastSpeed = document.getElementById('rear-fast-speed');
const rearDirArrow = document.getElementById('rear-dir-arrow');
const rearDirText = document.getElementById('rear-dir-text');
const rearPlateText = document.getElementById('rear-plate-text');
const rearModelText = document.getElementById('rear-model-text');

// Patrol
const patrolCard = document.getElementById('patrol-radar-card');
const patrolSpeed = document.getElementById('patrol-speed');

// Remote buttons
const rcToggleFront = document.getElementById('rc-toggle-front');
const rcToggleRear = document.getElementById('rc-toggle-rear');
const rcLockFront = document.getElementById('rc-lock-front');
const rcLockRear = document.getElementById('rc-lock-rear');
const rcUnlockAll = document.getElementById('rc-unlock-all');
const rcToggleTheme = document.getElementById('rc-toggle-theme');
const rcToggleUnit = document.getElementById('rc-toggle-unit');
const rcToggleAudio = document.getElementById('rc-toggle-audio');
const rcLimitMinus = document.getElementById('rc-limit-minus');
const rcLimitPlus = document.getElementById('rc-limit-plus');
const rcLimitDisplay = document.getElementById('rc-limit-display');
const rcResetPos = document.getElementById('rc-reset-pos');

// Inicializar AudioContext al primer gesto o evento
function initAudio() {
    if (!isAudioContextInit) {
        try {
            const AudioContext = window.AudioContext || window.webkitAudioContext;
            audioCtx = new AudioContext();
            isAudioContextInit = true;
        } catch (e) {
            console.warn("AudioContext not supported", e);
        }
    }
}

// Generador de sonidos realistas de radar policial por Web Audio API
function playSyntheticSound(type) {
    if (!audioEnabled) return;
    initAudio();
    if (!audioCtx) return;

    if (audioCtx.state === 'suspended') {
        audioCtx.resume();
    }

    const now = audioCtx.currentTime;

    if (type === 'lock') {
        // Doble tono agudo de bloqueo policial
        const osc1 = audioCtx.createOscillator();
        const gain1 = audioCtx.createGain();
        osc1.type = 'sine';
        osc1.frequency.setValueAtTime(1600, now);
        osc1.frequency.exponentialRampToValueAtTime(2200, now + 0.08);
        gain1.gain.setValueAtTime(0.2, now);
        gain1.gain.exponentialRampToValueAtTime(0.01, now + 0.12);
        osc1.connect(gain1);
        gain1.connect(audioCtx.destination);
        osc1.start(now);
        osc1.stop(now + 0.12);

        const osc2 = audioCtx.createOscillator();
        const gain2 = audioCtx.createGain();
        osc2.type = 'sine';
        osc2.frequency.setValueAtTime(2200, now + 0.14);
        osc2.frequency.setValueAtTime(2400, now + 0.22);
        gain2.gain.setValueAtTime(0.25, now + 0.14);
        gain2.gain.exponentialRampToValueAtTime(0.01, now + 0.26);
        osc2.connect(gain2);
        gain2.connect(audioCtx.destination);
        osc2.start(now + 0.14);
        osc2.stop(now + 0.26);

    } else if (type === 'beep') {
        // Tono sutil de detección
        const osc = audioCtx.createOscillator();
        const gain = audioCtx.createGain();
        osc.type = 'triangle';
        osc.frequency.setValueAtTime(950, now);
        gain.gain.setValueAtTime(0.08, now);
        gain.gain.exponentialRampToValueAtTime(0.001, now + 0.05);
        osc.connect(gain);
        gain.connect(audioCtx.destination);
        osc.start(now);
        osc.stop(now + 0.05);

    } else if (type === 'fast_alert') {
        // Alerta triple de exceso de velocidad
        for (let i = 0; i < 3; i++) {
            const time = now + (i * 0.1);
            const osc = audioCtx.createOscillator();
            const gain = audioCtx.createGain();
            osc.type = 'square';
            osc.frequency.setValueAtTime(1800, time);
            osc.frequency.setValueAtTime(1400, time + 0.04);
            gain.gain.setValueAtTime(0.15, time);
            gain.gain.exponentialRampToValueAtTime(0.01, time + 0.08);
            osc.connect(gain);
            gain.connect(audioCtx.destination);
            osc.start(time);
            osc.stop(time + 0.08);
        }
    }
}

// Aplicar interruptores de Config.Features
function applyFeaturesConfig(features) {
    if (!features) return;

    if (frontCard) frontCard.style.display = features.EnableFrontRadar ? 'block' : 'none';
    if (rearCard) rearCard.style.display = features.EnableRearRadar ? 'block' : 'none';
    if (patrolCard) patrolCard.style.display = features.ShowPatrolSpeed ? 'block' : 'none';

    // Matrículas
    const frontPlateEl = document.getElementById('block-front-plate');
    const rearPlateEl = document.getElementById('block-rear-plate');
    if (frontPlateEl) frontPlateEl.style.display = features.ShowVehiclePlate ? 'block' : 'none';
    if (rearPlateEl) rearPlateEl.style.display = features.ShowVehiclePlate ? 'block' : 'none';

    // Modelos
    const frontModelEl = document.getElementById('block-front-model');
    const rearModelEl = document.getElementById('block-rear-model');
    if (frontModelEl) frontModelEl.style.display = features.ShowVehicleModel ? 'block' : 'none';
    if (rearModelEl) rearModelEl.style.display = features.ShowVehicleModel ? 'block' : 'none';

    // Velocidades
    const frontTargetEl = document.getElementById('block-front-target');
    const rearTargetEl = document.getElementById('block-rear-target');
    if (frontTargetEl) frontTargetEl.style.display = features.ShowTargetSpeed ? 'block' : 'none';
    if (rearTargetEl) rearTargetEl.style.display = features.ShowTargetSpeed ? 'block' : 'none';

    const frontFastEl = document.getElementById('block-front-fast');
    const rearFastEl = document.getElementById('block-rear-fast');
    if (frontFastEl) frontFastEl.style.display = features.ShowFastSpeed ? 'block' : 'none';
    if (rearFastEl) rearFastEl.style.display = features.ShowFastSpeed ? 'block' : 'none';

    const frontDirEl = document.getElementById('block-front-dir');
    const rearDirEl = document.getElementById('block-rear-dir');
    if (frontDirEl) frontDirEl.style.display = features.ShowDirectionArrow ? 'block' : 'none';
    if (rearDirEl) rearDirEl.style.display = features.ShowDirectionArrow ? 'block' : 'none';

    // Control remoto botón en header
    const remoteBtn = document.getElementById('btn-open-remote');
    if (remoteBtn) remoteBtn.style.display = features.EnableRemoteControl ? 'block' : 'none';
}

// Cambiar y aplicar tema estético
function applyTheme(theme) {
    currentTheme = theme || 'modern_hud';
    radarContainer.classList.remove('theme-modern-hud', 'theme-classic-radar');
    
    if (currentTheme === 'classic_radar') {
        radarContainer.classList.add('theme-classic-radar');
        if (rcToggleTheme) rcToggleTheme.textContent = 'TEMA: CLÁSICO';
    } else {
        radarContainer.classList.add('theme-modern-hud');
        if (rcToggleTheme) rcToggleTheme.textContent = 'TEMA: HUD';
    }
}

// Formatear velocidad según el tema (HUD = 0, 45 / CLÁSICO = 000, 045)
function padSpeed(speed) {
    if (speed === null || speed === undefined || isNaN(speed)) {
        return currentTheme === 'classic_radar' ? '---' : '0';
    }
    const num = Math.round(speed);
    if (num < 0) return '0';
    
    if (currentTheme === 'classic_radar') {
        if (num < 10) return '00' + num;
        if (num < 100) return '0' + num;
        return '' + num;
    }
    return '' + num;
}

// Mensajes recibidos de FiveM (Lua)
window.addEventListener('message', function (event) {
    const data = event.data;
    if (!data || !data.action) return;

    if (data.action === 'openRadar') {
        radarContainer.style.display = 'block';
        if (data.theme) {
            applyTheme(data.theme);
        } else {
            const savedTheme = localStorage.getItem('cik_radar_theme') || 'modern_hud';
            applyTheme(savedTheme);
        }
        if (data.features) applyFeaturesConfig(data.features);
        if (data.speedUnit) {
            speedUnit = data.speedUnit;
            updateSpeedUnitLabels();
        }
        if (data.fastLimit) {
            fastLimit = data.fastLimit;
            rcLimitDisplay.textContent = `${fastLimit} ${speedUnit}`;
        }
    } else if (data.action === 'closeRadar') {
        radarContainer.style.display = 'none';
        remoteContainer.style.display = 'none';
    } else if (data.action === 'updateRadarData') {
        // Velocidad patrulla y barra de progreso
        patrolSpeed.textContent = padSpeed(data.patrolSpeed);
        const patrolBarFill = document.querySelector('.patrol-bar-fill');
        if (patrolBarFill) {
            const pSpeed = Number(data.patrolSpeed) || 0;
            const pct = Math.min(100, Math.max(15, (pSpeed / (fastLimit || 120)) * 100));
            patrolBarFill.style.width = pct + '%';
        }

        // Antena Delantera
        if (data.front) {
            updateAntennaUI('front', data.front);
        }

        // Antena Trasera
        if (data.rear) {
            updateAntennaUI('rear', data.rear);
        }

    } else if (data.action === 'openRemote') {
        remoteContainer.style.display = 'block';
    } else if (data.action === 'closeRemote') {
        remoteContainer.style.display = 'none';
    } else if (data.action === 'playSound') {
        playSyntheticSound(data.sound);
    }
});

// Actualiza una de las antenas (front o rear)
function updateAntennaUI(antenna, info) {
    const isFront = antenna === 'front';
    const card = isFront ? frontCard : rearCard;
    const modeBadge = isFront ? frontModeBadge : rearModeBadge;
    const lockBadge = isFront ? frontLockBadge : rearLockBadge;
    const targetEl = isFront ? frontTargetSpeed : rearTargetSpeed;
    const fastEl = isFront ? frontFastSpeed : rearFastSpeed;
    const dirArrow = isFront ? frontDirArrow : rearDirArrow;
    const dirText = isFront ? frontDirText : rearDirText;
    const plateEl = isFront ? frontPlateText : rearPlateText;
    const modelEl = isFront ? frontModelText : rearModelText;
    const rcLockBtn = isFront ? rcLockFront : rcLockRear;
    const hudBar = document.getElementById(isFront ? 'front-hud-bar' : 'rear-hud-bar');

    // Estado XMIT o HOLD
    if (info.active) {
        modeBadge.textContent = 'XMIT';
        modeBadge.className = 'mode-pill xmit';
    } else {
        modeBadge.textContent = 'HOLD';
        modeBadge.className = 'mode-pill hold';
    }

    // Estado Bloqueado o Escaneando
    if (info.locked) {
        lockBadge.textContent = 'LOCK';
        lockBadge.className = 'mode-pill locked';
        card.classList.add('locked-state');
        if (hudBar) {
            hudBar.classList.add('locked');
            hudBar.classList.remove('overspeed');
        }
        if (rcLockBtn) {
            rcLockBtn.classList.add('locked');
            rcLockBtn.textContent = isFront ? 'DESBLOQ DELANTERO' : 'DESBLOQ TRASERO';
        }
    } else {
        lockBadge.textContent = 'SCAN';
        lockBadge.className = 'mode-pill scan';
        card.classList.remove('locked-state');
        if (hudBar) {
            hudBar.classList.remove('locked');
        }
        if (rcLockBtn) {
            rcLockBtn.classList.remove('locked');
            rcLockBtn.textContent = isFront ? 'FIJAR DELANTERO' : 'FIJAR TRASERO';
        }
    }

    // Datos de velocidad
    if (info.hasTarget) {
        targetEl.textContent = padSpeed(info.targetSpeed);
        if (info.fastSpeed) {
            fastEl.textContent = padSpeed(info.fastSpeed);
        }

        // Alerta de exceso de velocidad
        if (info.isOverSpeed) {
            targetEl.classList.add('alert-overspeed');
            if (hudBar) hudBar.classList.add('overspeed');
        } else {
            targetEl.classList.remove('alert-overspeed');
            if (hudBar) hudBar.classList.remove('overspeed');
        }

        // Barra inferior amarilla proporcional
        if (hudBar && !info.locked) {
            const pct = Math.min(100, Math.max(15, (Number(info.targetSpeed) / (fastLimit || 120)) * 100));
            hudBar.style.width = pct + '%';
        }

        // Dirección
        if (info.direction === 'SAME') {
            dirArrow.textContent = '▲';
            dirArrow.style.color = '#ffff00';
            dirText.textContent = 'MISMO';
        } else if (info.direction === 'OPP') {
            dirArrow.textContent = '▼';
            dirArrow.style.color = '#ff9900';
            dirText.textContent = 'CONT';
        } else {
            dirArrow.textContent = '--';
            dirText.textContent = '--';
        }

        // Matrícula y modelo
        plateEl.textContent = info.plate || '--------';
        modelEl.textContent = info.model || 'DESCONOCIDO';
    } else if (!info.locked) {
        targetEl.textContent = '0';
        targetEl.classList.remove('alert-overspeed');
        if (hudBar) {
            hudBar.classList.remove('overspeed');
            hudBar.style.width = '10%';
        }
        dirArrow.textContent = '--';
        dirText.textContent = '--';
        plateEl.textContent = '--------';
        modelEl.textContent = 'SIN OBJETIVO';
    }
}

function updateSpeedUnitLabels() {
    const units = document.querySelectorAll('.speed-unit-text');
    units.forEach(u => u.textContent = speedUnit);
    rcToggleUnit.textContent = `UNIDAD: ${speedUnit}`;
    rcLimitDisplay.textContent = `${fastLimit} ${speedUnit}`;
}

// ==========================================================
//               INTERACCIÓN CON CONTROL REMOTO
// ==========================================================

function sendNuiCallback(event, data = {}) {
    fetch(`https://${GetParentResourceName()}/${event}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify(data)
    }).catch(err => console.log('NUI Fetch Error:', err));
}

document.getElementById('btn-open-remote').addEventListener('click', () => {
    sendNuiCallback('openRemoteFromUI');
});

document.getElementById('btn-close-remote').addEventListener('click', () => {
    sendNuiCallback('closeRemote');
});

rcToggleFront.addEventListener('click', () => {
    sendNuiCallback('toggleFrontAntenna');
});

rcToggleRear.addEventListener('click', () => {
    sendNuiCallback('toggleRearAntenna');
});

rcLockFront.addEventListener('click', () => {
    sendNuiCallback('lockFront');
});

rcLockRear.addEventListener('click', () => {
    sendNuiCallback('lockRear');
});

rcUnlockAll.addEventListener('click', () => {
    sendNuiCallback('unlockAll');
});

rcToggleTheme.addEventListener('click', () => {
    const nextTheme = currentTheme === 'modern_hud' ? 'classic_radar' : 'modern_hud';
    applyTheme(nextTheme);
    localStorage.setItem('cik_radar_theme', nextTheme);
    sendNuiCallback('changeTheme', { theme: nextTheme });
});

rcToggleUnit.addEventListener('click', () => {
    speedUnit = speedUnit === 'KMH' ? 'MPH' : 'KMH';
    updateSpeedUnitLabels();
    sendNuiCallback('changeSpeedUnit', { unit: speedUnit });
});

rcToggleAudio.addEventListener('click', () => {
    audioEnabled = !audioEnabled;
    if (audioEnabled) {
        rcToggleAudio.classList.add('active');
        rcToggleAudio.textContent = 'AUDIO: ON';
    } else {
        rcToggleAudio.classList.remove('active');
        rcToggleAudio.textContent = 'AUDIO: OFF';
    }
    sendNuiCallback('toggleAudio', { enabled: audioEnabled });
});

rcLimitMinus.addEventListener('click', () => {
    if (fastLimit > 20) {
        fastLimit -= 10;
        rcLimitDisplay.textContent = `${fastLimit} ${speedUnit}`;
        sendNuiCallback('setFastLimit', { limit: fastLimit });
    }
});

rcLimitPlus.addEventListener('click', () => {
    if (fastLimit < 300) {
        fastLimit += 10;
        rcLimitDisplay.textContent = `${fastLimit} ${speedUnit}`;
        sendNuiCallback('setFastLimit', { limit: fastLimit });
    }
});

rcResetPos.addEventListener('click', () => {
    radarContainer.style.top = '';
    radarContainer.style.left = '';
    radarContainer.style.bottom = '40px';
    radarContainer.style.right = '40px';
    localStorage.removeItem('cik_radar_pos');
});

// Cerrar con Escape
window.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
        if (remoteContainer.style.display === 'block') {
            sendNuiCallback('closeRemote');
        }
    }
});

// ==========================================================
//               SISTEMA DE ARRASTRE (DRAG & DROP)
// ==========================================================

(function initDraggable() {
    const header = document.getElementById('radar-header');
    let isDragging = false;
    let startX, startY, initialLeft, initialTop;

    // Cargar posición guardada si existe
    const savedPos = localStorage.getItem('cik_radar_pos');
    if (savedPos) {
        try {
            const pos = JSON.parse(savedPos);
            radarContainer.style.bottom = 'auto';
            radarContainer.style.right = 'auto';
            radarContainer.style.left = `${pos.x}px`;
            radarContainer.style.top = `${pos.y}px`;
        } catch (e) {
            console.error(e);
        }
    }

    header.addEventListener('mousedown', (e) => {
        if (e.target.tagName === 'BUTTON') return;
        isDragging = true;
        startX = e.clientX;
        startY = e.clientY;

        const rect = radarContainer.getBoundingClientRect();
        initialLeft = rect.left;
        initialTop = rect.top;

        document.addEventListener('mousemove', onMouseMove);
        document.addEventListener('mouseup', onMouseUp);
    });

    function onMouseMove(e) {
        if (!isDragging) return;
        const dx = e.clientX - startX;
        const dy = e.clientY - startY;

        let newX = initialLeft + dx;
        let newY = initialTop + dy;

        // Limitar dentro de la pantalla
        newX = Math.max(10, Math.min(window.innerWidth - radarContainer.offsetWidth - 10, newX));
        newY = Math.max(10, Math.min(window.innerHeight - radarContainer.offsetHeight - 10, newY));

        radarContainer.style.bottom = 'auto';
        radarContainer.style.right = 'auto';
        radarContainer.style.left = `${newX}px`;
        radarContainer.style.top = `${newY}px`;
    }

    function onMouseUp() {
        if (!isDragging) return;
        isDragging = false;
        document.removeEventListener('mousemove', onMouseMove);
        document.removeEventListener('mouseup', onMouseUp);

        // Guardar posición
        const rect = radarContainer.getBoundingClientRect();
        localStorage.setItem('cik_radar_pos', JSON.stringify({ x: rect.left, y: rect.top }));
    }
})();

