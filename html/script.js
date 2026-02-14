// ============================================
// uSkin - NUI Script
// Vanilla JS UI for character customization
// ============================================

// ============================================
// NUI Communication
// ============================================
function postNUI(name, data) {
    return fetch(`https://${GetParentResourceName()}/${name}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data || {}),
    }).then(r => r.json()).catch(() => ({}));
}

// ============================================
// State
// ============================================
let state = {
    config: null,
    data: null,
    storedData: null,
    settings: null,
    camera: { head: false, body: false, bottom: false },
    rotate: { left: false, right: false },
    clothes: { head: true, body: true, bottom: true },
};

// ============================================
// DOM References
// ============================================
const container = document.getElementById('uSkin-container');
const panel = document.getElementById('uSkin-sections');
const optionsBar = document.getElementById('uSkin-options');

// ============================================
// Helpers
// ============================================
function formatValue(val, step) {
    if (step && step < 1) return val.toFixed(1);
    return String(Math.round(val));
}

function humanize(key) {
    return key
        .replace(/([A-Z])/g, ' $1')
        .replace(/([a-z])(\d)/g, '$1 $2')
        .replace(/^./, s => s.toUpperCase())
        .trim();
}

function isFreemode() {
    return state.data && (
        state.data.model === 'mp_m_freemode_01' ||
        state.data.model === 'mp_f_freemode_01'
    );
}

function findComponentSettings(id) {
    if (!state.settings || !state.settings.components) return null;
    return state.settings.components.find(c => c.component_id === id);
}

function findComponentData(id) {
    if (!state.data || !state.data.components) return null;
    return state.data.components.find(c => c.component_id === id);
}

function findPropSettings(id) {
    if (!state.settings || !state.settings.props) return null;
    return state.settings.props.find(p => p.prop_id === id);
}

function findPropData(id) {
    if (!state.data || !state.data.props) return null;
    return state.data.props.find(p => p.prop_id === id);
}

function updateComponentSettings(id, newSettings) {
    if (!state.settings || !state.settings.components) return;
    const idx = state.settings.components.findIndex(c => c.component_id === id);
    if (idx !== -1) state.settings.components[idx] = newSettings;
}

function updatePropSettings(id, newSettings) {
    if (!state.settings || !state.settings.props) return;
    const idx = state.settings.props.findIndex(p => p.prop_id === id);
    if (idx !== -1) state.settings.props[idx] = newSettings;
}

// ============================================
// Label Maps
// ============================================
const COMPONENT_LABELS = {
    1: 'Masks', 3: 'Upper Body', 4: 'Lower Body', 5: 'Bags',
    6: 'Shoes', 7: 'Accessories', 8: 'Undershirts', 9: 'Body Armor',
    10: 'Decals', 11: 'Tops',
};

const PROP_LABELS = {
    0: 'Hats', 1: 'Glasses', 2: 'Ears', 6: 'Watches', 7: 'Bracelets',
};

const OVERLAY_LABELS = {
    blemishes: 'Blemishes', beard: 'Beard', eyebrows: 'Eyebrows',
    ageing: 'Ageing', makeUp: 'Makeup', blush: 'Blush',
    complexion: 'Complexion', sunDamage: 'Sun Damage', lipstick: 'Lipstick',
    moleAndFreckles: 'Moles & Freckles', chestHair: 'Chest Hair',
    bodyBlemishes: 'Body Blemishes',
};

const FACE_GROUPS = [
    { label: 'Nose', keys: ['noseWidth', 'nosePeakHigh', 'nosePeakSize', 'noseBoneHigh', 'nosePeakLowering', 'noseBoneTwist'] },
    { label: 'Eyebrows', keys: ['eyeBrownHigh', 'eyeBrownForward'] },
    { label: 'Cheeks', keys: ['cheeksBoneHigh', 'cheeksBoneWidth', 'cheeksWidth'] },
    { label: 'Eyes & Mouth', keys: ['eyesOpening', 'lipsThickness'] },
    { label: 'Jaw', keys: ['jawBoneWidth', 'jawBoneBackSize'] },
    { label: 'Chin', keys: ['chinBoneLowering', 'chinBoneLenght', 'chinBoneSize', 'chinHole'] },
    { label: 'Neck', keys: ['neckThickness'] },
];

// Overlay order (matches Config.headOverlays)
const OVERLAY_ORDER = [
    'blemishes', 'beard', 'eyebrows', 'ageing', 'makeUp', 'blush',
    'complexion', 'sunDamage', 'lipstick', 'moleAndFreckles', 'chestHair', 'bodyBlemishes',
];

// ============================================
// SVG Icons (inline, no external deps)
// ============================================
const ICONS = {
    camera: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z"/><circle cx="12" cy="13" r="4"/></svg>',
    face: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="M8 14s1.5 2 4 2 4-2 4-2"/><line x1="9" y1="9" x2="9.01" y2="9"/><line x1="15" y1="9" x2="15.01" y2="9"/></svg>',
    body: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>',
    shoe: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M2 18h20v2H2z"/><path d="M4 14l2-6h4l1 3h5l4 3"/></svg>',
    turnAround: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 1l4 4-4 4"/><path d="M3 11V9a4 4 0 0 1 4-4h14"/><path d="M7 23l-4-4 4-4"/><path d="M21 13v2a4 4 0 0 1-4 4H3"/></svg>',
    rotateLeft: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="1 4 1 10 7 10"/><path d="M3.51 15a9 9 0 1 0 2.13-9.36L1 10"/></svg>',
    rotateRight: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="23 4 23 10 17 10"/><path d="M20.49 15a9 9 0 1 1-2.12-9.36L23 10"/></svg>',
    save: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/><polyline points="17 21 17 13 7 13 7 21"/><polyline points="7 3 7 8 15 8"/></svg>',
    exit: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>',
    hat: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 2L2 12h3v6h14v-6h3L12 2z"/></svg>',
    shirt: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 7l-4-4H8L4 7l4 2v12h8V9l4-2z"/></svg>',
    pants: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M6 2h12v8l-2 12h-3l-1-8-1 8H8L6 10V2z"/></svg>',
};

// ============================================
// Component Builders
// ============================================

/**
 * Creates a collapsible section
 */
function createSection(title, contentFn) {
    const section = document.createElement('div');
    section.className = 'uskin-section';

    const header = document.createElement('div');
    header.className = 'uskin-section-header';

    const titleEl = document.createElement('span');
    titleEl.className = 'uskin-section-title';
    titleEl.textContent = title;

    const chevron = document.createElement('span');
    chevron.className = 'uskin-section-chevron';
    chevron.innerHTML = '&#9662;';

    header.appendChild(titleEl);
    header.appendChild(chevron);

    const content = document.createElement('div');
    content.className = 'uskin-section-content';

    const inner = document.createElement('div');
    inner.className = 'uskin-section-content-inner';

    const contentEl = contentFn();
    if (contentEl) {
        if (contentEl instanceof DocumentFragment || contentEl instanceof HTMLElement) {
            inner.appendChild(contentEl);
        }
    }
    content.appendChild(inner);

    header.addEventListener('click', () => {
        const isOpen = header.classList.toggle('open');
        if (isOpen) {
            content.classList.add('open');
            content.style.maxHeight = content.scrollHeight + 'px';
            setTimeout(() => {
                if (content.classList.contains('open')) {
                    content.style.maxHeight = 'none';
                }
            }, 300);
        } else {
            content.style.maxHeight = content.scrollHeight + 'px';
            content.offsetHeight; // force reflow
            content.style.maxHeight = '0';
            content.classList.remove('open');
        }
    });

    section.appendChild(header);
    section.appendChild(content);
    return section;
}

/**
 * Creates a sub-item group within a section
 */
function createItem(title, children) {
    const item = document.createElement('div');
    item.className = 'uskin-item';

    if (title) {
        const titleEl = document.createElement('div');
        titleEl.className = 'uskin-item-title';
        titleEl.textContent = title;
        item.appendChild(titleEl);
    }

    if (Array.isArray(children)) {
        children.forEach(child => { if (child) item.appendChild(child); });
    } else if (children) {
        item.appendChild(children);
    }

    return item;
}

/**
 * Creates a range slider control
 */
function createRangeInput(opts) {
    const wrapper = document.createElement('div');
    wrapper.className = 'uskin-range';

    const label = document.createElement('div');
    label.className = 'uskin-range-label';

    const nameEl = document.createElement('span');
    nameEl.className = 'uskin-range-name';
    nameEl.textContent = opts.title || '';

    const valueEl = document.createElement('span');
    valueEl.className = 'uskin-range-value';
    valueEl.textContent = formatValue(opts.value, opts.step);

    label.appendChild(nameEl);
    label.appendChild(valueEl);

    const track = document.createElement('div');
    track.className = 'uskin-range-track';

    const fill = document.createElement('div');
    fill.className = 'uskin-range-fill';

    const thumb = document.createElement('div');
    thumb.className = 'uskin-range-thumb';

    track.appendChild(fill);
    track.appendChild(thumb);

    function updateVisual(val) {
        const pct = ((val - opts.min) / (opts.max - opts.min)) * 100;
        fill.style.width = pct + '%';
        thumb.style.left = pct + '%';
        valueEl.textContent = formatValue(val, opts.step);
    }

    updateVisual(opts.value);

    let dragging = false;

    function calcValue(e) {
        const rect = track.getBoundingClientRect();
        let pct = (e.clientX - rect.left) / rect.width;
        pct = Math.max(0, Math.min(1, pct));
        let val = opts.min + pct * (opts.max - opts.min);
        const step = opts.step || 1;
        val = Math.round(val / step) * step;
        val = Math.max(opts.min, Math.min(opts.max, val));
        return parseFloat(val.toFixed(4));
    }

    track.addEventListener('mousedown', (e) => {
        dragging = true;
        track.classList.add('active');
        const val = calcValue(e);
        opts.value = val;
        updateVisual(val);
        if (opts.onChange) opts.onChange(val);
    });

    document.addEventListener('mousemove', (e) => {
        if (!dragging) return;
        const val = calcValue(e);
        opts.value = val;
        updateVisual(val);
        if (opts.onChange) opts.onChange(val);
    });

    document.addEventListener('mouseup', () => {
        if (dragging) {
            dragging = false;
            track.classList.remove('active');
        }
    });

    wrapper.appendChild(label);
    wrapper.appendChild(track);

    wrapper._update = (val) => {
        opts.value = val;
        updateVisual(val);
    };

    return wrapper;
}

/**
 * Creates a number input with increment/decrement buttons
 */
function createNumberInput(opts) {
    const wrapper = document.createElement('div');
    wrapper.className = 'uskin-number';

    const label = document.createElement('div');
    label.className = 'uskin-number-label';

    const nameEl = document.createElement('span');
    nameEl.className = 'uskin-number-name';
    nameEl.textContent = opts.title || '';

    label.appendChild(nameEl);

    const controls = document.createElement('div');
    controls.className = 'uskin-number-controls';

    const decBtn = document.createElement('button');
    decBtn.className = 'uskin-number-btn';
    decBtn.innerHTML = '&#8722;';
    decBtn.type = 'button';

    const display = document.createElement('span');
    display.className = 'uskin-number-display';
    display.textContent = opts.value;

    const incBtn = document.createElement('button');
    incBtn.className = 'uskin-number-btn';
    incBtn.innerHTML = '&#43;';
    incBtn.type = 'button';

    decBtn.addEventListener('click', () => {
        const step = opts.step || 1;
        let newVal = opts.value - step;
        if (newVal < opts.min) newVal = opts.max; // wrap around
        newVal = parseFloat(newVal.toFixed(4));
        opts.value = newVal;
        display.textContent = newVal;
        if (opts.onChange) opts.onChange(newVal);
    });

    incBtn.addEventListener('click', () => {
        const step = opts.step || 1;
        let newVal = opts.value + step;
        if (newVal > opts.max) newVal = opts.min; // wrap around
        newVal = parseFloat(newVal.toFixed(4));
        opts.value = newVal;
        display.textContent = newVal;
        if (opts.onChange) opts.onChange(newVal);
    });

    controls.appendChild(decBtn);
    controls.appendChild(display);
    controls.appendChild(incBtn);

    wrapper.appendChild(label);
    wrapper.appendChild(controls);

    wrapper._update = (val) => {
        opts.value = val;
        display.textContent = val;
    };

    wrapper._updateRange = (newMin, newMax) => {
        opts.min = newMin;
        opts.max = newMax;
    };

    return wrapper;
}

/**
 * Creates a color swatch picker
 */
function createColorInput(opts) {
    const wrapper = document.createElement('div');
    wrapper.className = 'uskin-colors';

    const label = document.createElement('div');
    label.className = 'uskin-colors-label';

    const nameEl = document.createElement('span');
    nameEl.className = 'uskin-colors-name';
    nameEl.textContent = opts.title || '';

    label.appendChild(nameEl);

    const grid = document.createElement('div');
    grid.className = 'uskin-colors-grid';

    let selectedBtn = null;

    (opts.colors || []).forEach((color, index) => {
        const btn = document.createElement('button');
        btn.className = 'uskin-color-btn';
        btn.type = 'button';
        btn.style.backgroundColor = `rgb(${color[0]}, ${color[1]}, ${color[2]})`;

        if (index === opts.value) {
            btn.classList.add('selected');
            selectedBtn = btn;
        }

        btn.addEventListener('click', () => {
            if (selectedBtn) selectedBtn.classList.remove('selected');
            btn.classList.add('selected');
            selectedBtn = btn;
            opts.value = index;
            if (opts.onChange) opts.onChange(index);
        });

        grid.appendChild(btn);
    });

    wrapper.appendChild(label);
    wrapper.appendChild(grid);
    return wrapper;
}

/**
 * Creates a native select dropdown
 */
function createSelectInput(opts) {
    const wrapper = document.createElement('div');
    wrapper.className = 'uskin-select';

    const label = document.createElement('label');
    label.className = 'uskin-select-label';
    label.textContent = opts.title || '';

    const select = document.createElement('select');
    select.className = 'uskin-select-control';

    (opts.items || []).forEach((item, index) => {
        const option = document.createElement('option');
        option.value = typeof item === 'object' ? item.value : item;
        option.textContent = typeof item === 'object' ? item.label : item;
        if (option.value === opts.value || index === opts.value) {
            option.selected = true;
        }
        select.appendChild(option);
    });

    select.addEventListener('change', () => {
        if (opts.onChange) opts.onChange(select.value);
    });

    wrapper.appendChild(label);
    wrapper.appendChild(select);
    return wrapper;
}

// ============================================
// Section Builders
// ============================================

function buildPedSection() {
    return createSection('Ped Model', () => {
        const frag = document.createDocumentFragment();
        const items = state.settings.ped.model.items || [];
        frag.appendChild(createSelectInput({
            title: 'Model',
            items: items,
            value: state.data.model,
            onChange: async (val) => {
                state.data.model = val;
                const result = await postNUI('appearance_change_model', val);
                if (result && result.appearanceSettings && result.appearanceData) {
                    state.settings = result.appearanceSettings;
                    state.data = result.appearanceData;
                    buildUI();
                }
            },
        }));
        return frag;
    });
}

function buildHeadBlendSection() {
    const s = state.settings.headBlend;
    const d = state.data.headBlend;
    if (!s || !d) return null;

    function onChange(key, val) {
        d[key] = val;
        postNUI('appearance_change_head_blend', d);
    }

    return createSection('Genetics', () => {
        const frag = document.createDocumentFragment();

        frag.appendChild(createItem('Shape', [
            createNumberInput({ title: 'Mother', min: s.shapeFirst.min, max: s.shapeFirst.max, value: d.shapeFirst, onChange: v => onChange('shapeFirst', v) }),
            createNumberInput({ title: 'Father', min: s.shapeSecond.min, max: s.shapeSecond.max, value: d.shapeSecond, onChange: v => onChange('shapeSecond', v) }),
            createRangeInput({ title: 'Mix', min: s.shapeMix.min, max: s.shapeMix.max, step: s.shapeMix.factor, value: d.shapeMix, onChange: v => onChange('shapeMix', v) }),
        ]));

        frag.appendChild(createItem('Skin', [
            createNumberInput({ title: 'Mother', min: s.skinFirst.min, max: s.skinFirst.max, value: d.skinFirst, onChange: v => onChange('skinFirst', v) }),
            createNumberInput({ title: 'Father', min: s.skinSecond.min, max: s.skinSecond.max, value: d.skinSecond, onChange: v => onChange('skinSecond', v) }),
            createRangeInput({ title: 'Mix', min: s.skinMix.min, max: s.skinMix.max, step: s.skinMix.factor, value: d.skinMix, onChange: v => onChange('skinMix', v) }),
        ]));

        return frag;
    });
}

function buildFaceFeaturesSection() {
    const fs = state.settings.faceFeatures;
    const fd = state.data.faceFeatures;
    if (!fs || !fd) return null;

    function onChange(key, val) {
        fd[key] = val;
        postNUI('appearance_change_face_feature', fd);
    }

    return createSection('Face Features', () => {
        const frag = document.createDocumentFragment();

        FACE_GROUPS.forEach(group => {
            const sliders = group.keys.map(key => {
                const s = fs[key];
                if (!s) return null;
                return createRangeInput({
                    title: humanize(key),
                    min: s.min,
                    max: s.max,
                    step: s.factor,
                    value: fd[key] || 0,
                    onChange: v => onChange(key, v),
                });
            }).filter(Boolean);

            if (sliders.length > 0) {
                frag.appendChild(createItem(group.label, sliders));
            }
        });

        return frag;
    });
}

function buildHairSection() {
    const hs = state.settings.hair;
    const hd = state.data.hair;
    if (!hs || !hd) return null;

    function onChange() {
        postNUI('appearance_change_hair', hd);
    }

    return createSection('Hair', () => {
        const frag = document.createDocumentFragment();

        frag.appendChild(createNumberInput({
            title: 'Style',
            min: hs.style.min,
            max: hs.style.max,
            value: hd.style,
            onChange: v => { hd.style = v; onChange(); },
        }));

        if (hs.color && hs.color.items) {
            frag.appendChild(createColorInput({
                title: 'Color',
                colors: hs.color.items,
                value: hd.color,
                onChange: v => { hd.color = v; onChange(); },
            }));
        }

        if (hs.highlight && hs.highlight.items) {
            frag.appendChild(createColorInput({
                title: 'Highlight',
                colors: hs.highlight.items,
                value: hd.highlight,
                onChange: v => { hd.highlight = v; onChange(); },
            }));
        }

        return frag;
    });
}

function buildHeadOverlaysSection() {
    const os = state.settings.headOverlays;
    const od = state.data.headOverlays;
    if (!os || !od) return null;

    function onChange() {
        postNUI('appearance_change_head_overlay', od);
    }

    return createSection('Head Overlays', () => {
        const frag = document.createDocumentFragment();

        OVERLAY_ORDER.forEach(key => {
            const settings = os[key];
            const data = od[key];
            if (!settings || !data) return;

            const children = [];

            if (settings.style) {
                children.push(createNumberInput({
                    title: 'Style',
                    min: settings.style.min,
                    max: settings.style.max,
                    value: data.style,
                    onChange: v => { data.style = v; onChange(); },
                }));
            }

            if (settings.opacity) {
                children.push(createRangeInput({
                    title: 'Opacity',
                    min: settings.opacity.min,
                    max: settings.opacity.max,
                    step: settings.opacity.factor,
                    value: data.opacity,
                    onChange: v => { data.opacity = v; onChange(); },
                }));
            }

            if (settings.color && settings.color.items) {
                children.push(createColorInput({
                    title: 'Color',
                    colors: settings.color.items,
                    value: data.color,
                    onChange: v => { data.color = v; onChange(); },
                }));
            }

            if (children.length > 0) {
                frag.appendChild(createItem(OVERLAY_LABELS[key] || humanize(key), children));
            }
        });

        return frag;
    });
}

function buildEyeColorSection() {
    const es = state.settings.eyeColor;
    if (!es) return null;

    return createSection('Eye Color', () => {
        const frag = document.createDocumentFragment();
        frag.appendChild(createNumberInput({
            title: 'Color',
            min: es.min,
            max: es.max,
            value: state.data.eyeColor || 0,
            onChange: v => {
                state.data.eyeColor = v;
                postNUI('appearance_change_eye_color', v);
            },
        }));
        return frag;
    });
}

function buildComponentsSection() {
    const displayIds = [1, 3, 4, 5, 6, 7, 8, 9, 10, 11];

    return createSection('Clothing', () => {
        const frag = document.createDocumentFragment();

        displayIds.forEach(id => {
            const cs = findComponentSettings(id);
            const cd = findComponentData(id);
            if (!cs || !cd) return;

            let textureInput;

            const drawableInput = createNumberInput({
                title: 'Drawable',
                min: cs.drawable.min,
                max: cs.drawable.max,
                value: cd.drawable,
                onChange: async (v) => {
                    cd.drawable = v;
                    cd.texture = 0;
                    const newSettings = await postNUI('appearance_change_component', cd);
                    if (newSettings && newSettings.texture) {
                        updateComponentSettings(id, newSettings);
                        textureInput._update(0);
                        textureInput._updateRange(newSettings.texture.min, newSettings.texture.max);
                    }
                },
            });

            textureInput = createNumberInput({
                title: 'Texture',
                min: cs.texture.min,
                max: cs.texture.max,
                value: cd.texture,
                onChange: v => {
                    cd.texture = v;
                    postNUI('appearance_change_component', cd);
                },
            });

            frag.appendChild(createItem(COMPONENT_LABELS[id] || ('Component ' + id), [drawableInput, textureInput]));
        });

        return frag;
    });
}

function buildPropsSection() {
    const displayIds = [0, 1, 2, 6, 7];

    return createSection('Props', () => {
        const frag = document.createDocumentFragment();

        displayIds.forEach(id => {
            const ps = findPropSettings(id);
            const pd = findPropData(id);
            if (!ps || !pd) return;

            let textureInput;

            const drawableInput = createNumberInput({
                title: 'Drawable',
                min: ps.drawable.min,
                max: ps.drawable.max,
                value: pd.drawable,
                onChange: async (v) => {
                    pd.drawable = v;
                    pd.texture = 0;
                    const newSettings = await postNUI('appearance_change_prop', pd);
                    if (newSettings && newSettings.texture) {
                        updatePropSettings(id, newSettings);
                        textureInput._update(0);
                        textureInput._updateRange(newSettings.texture.min, newSettings.texture.max);
                    }
                },
            });

            textureInput = createNumberInput({
                title: 'Texture',
                min: ps.texture.min,
                max: ps.texture.max,
                value: pd.texture,
                onChange: v => {
                    pd.texture = v;
                    postNUI('appearance_change_prop', pd);
                },
            });

            frag.appendChild(createItem(PROP_LABELS[id] || ('Prop ' + id), [drawableInput, textureInput]));
        });

        return frag;
    });
}

function buildTattoosSection() {
    const tattooItems = state.settings.tattoos && state.settings.tattoos.items;
    if (!tattooItems) return null;

    // Ensure tattoos data object exists
    if (!state.data.tattoos) state.data.tattoos = {};

    const zones = Object.keys(tattooItems).filter(z => z !== 'ZONE_HAIR');
    if (zones.length === 0) return null;

    return createSection('Tattoos', () => {
        const frag = document.createDocumentFragment();

        const tabs = document.createElement('div');
        tabs.className = 'uskin-tattoo-tabs';

        const listContainer = document.createElement('div');
        listContainer.className = 'uskin-tattoo-list';

        let activeZone = zones[0];

        function renderZoneList(zone) {
            listContainer.innerHTML = '';
            const zoneTattoos = tattooItems[zone] || [];
            const applied = (state.data.tattoos && state.data.tattoos[zone]) || [];

            zoneTattoos.forEach(tattoo => {
                const isApplied = applied.some(t => t.name === tattoo.name);

                const row = document.createElement('div');
                row.className = 'uskin-tattoo-item';

                const name = document.createElement('span');
                name.className = 'uskin-tattoo-name';
                name.textContent = tattoo.label || tattoo.name;

                const actions = document.createElement('div');
                actions.className = 'uskin-tattoo-actions';

                if (isApplied) {
                    const delBtn = document.createElement('button');
                    delBtn.className = 'uskin-tattoo-btn delete';
                    delBtn.type = 'button';
                    delBtn.textContent = 'DELETE';
                    delBtn.addEventListener('click', () => {
                        if (!state.data.tattoos[zone]) return;
                        state.data.tattoos[zone] = state.data.tattoos[zone].filter(t => t.name !== tattoo.name);
                        postNUI('appearance_delete_tattoo', state.data.tattoos);
                        renderZoneList(zone);
                    });
                    actions.appendChild(delBtn);
                } else {
                    const applyBtn = document.createElement('button');
                    applyBtn.className = 'uskin-tattoo-btn apply';
                    applyBtn.type = 'button';
                    applyBtn.textContent = 'APPLY';
                    applyBtn.addEventListener('click', () => {
                        if (!state.data.tattoos[zone]) state.data.tattoos[zone] = [];
                        state.data.tattoos[zone].push(tattoo);
                        postNUI('appearance_apply_tattoo', state.data.tattoos);
                        renderZoneList(zone);
                    });
                    actions.appendChild(applyBtn);
                }

                row.addEventListener('mouseenter', () => {
                    postNUI('appearance_preview_tattoo', { data: state.data.tattoos, tattoo: tattoo });
                });

                row.appendChild(name);
                row.appendChild(actions);
                listContainer.appendChild(row);
            });

            if (zoneTattoos.length === 0) {
                const empty = document.createElement('div');
                empty.className = 'uskin-tattoo-name';
                empty.style.padding = '12px';
                empty.style.textAlign = 'center';
                empty.style.color = '#8a8a8a';
                empty.textContent = 'No tattoos available';
                listContainer.appendChild(empty);
            }
        }

        zones.forEach(zone => {
            const tab = document.createElement('button');
            tab.className = 'uskin-tattoo-tab';
            tab.type = 'button';
            tab.textContent = zone.replace('ZONE_', '').replace(/_/g, ' ');
            if (zone === activeZone) tab.classList.add('active');
            tab.addEventListener('click', () => {
                tabs.querySelectorAll('.uskin-tattoo-tab').forEach(t => t.classList.remove('active'));
                tab.classList.add('active');
                activeZone = zone;
                renderZoneList(zone);
            });
            tabs.appendChild(tab);
        });

        frag.appendChild(tabs);
        frag.appendChild(listContainer);
        renderZoneList(activeZone);

        return frag;
    });
}

// ============================================
// Options Toolbar
// ============================================

function createOptButton(iconSvg, title, onClick) {
    const btn = document.createElement('button');
    btn.className = 'uskin-opt-btn';
    btn.type = 'button';
    btn.innerHTML = iconSvg;
    btn.title = title;
    btn.addEventListener('click', onClick);
    return btn;
}

function createOptGroup(groupIcon, items, onItemClick, exclusive) {
    const group = document.createElement('div');
    group.className = 'uskin-opt-group';

    const icon = document.createElement('div');
    icon.className = 'uskin-opt-group-icon';
    icon.innerHTML = groupIcon;

    const itemsContainer = document.createElement('div');
    itemsContainer.className = 'uskin-opt-group-items';

    const buttons = [];

    items.forEach(item => {
        const btn = document.createElement('button');
        btn.className = 'uskin-opt-btn';
        btn.type = 'button';
        btn.innerHTML = item.icon;
        btn.title = item.title;

        if (item.active) btn.classList.add('active');

        btn.addEventListener('click', () => {
            if (exclusive) {
                const wasActive = btn.classList.contains('active');
                buttons.forEach(b => b.classList.remove('active'));
                if (!wasActive) btn.classList.add('active');
            } else {
                btn.classList.toggle('active');
            }
            onItemClick(item.key, btn);
        });

        buttons.push(btn);
        itemsContainer.appendChild(btn);
    });

    group.appendChild(icon);
    group.appendChild(itemsContainer);
    return group;
}

function buildOptionsBar() {
    // Camera group (exclusive: only one camera preset at a time)
    const cameraGroup = createOptGroup(ICONS.camera, [
        { icon: ICONS.face, title: 'Head', key: 'head' },
        { icon: ICONS.body, title: 'Body', key: 'body' },
        { icon: ICONS.shoe, title: 'Feet', key: 'bottom' },
    ], (key, btn) => {
        const wasActive = state.camera[key];
        Object.keys(state.camera).forEach(k => { state.camera[k] = false; });
        if (!wasActive) {
            state.camera[key] = true;
            postNUI('appearance_set_camera', key);
        } else {
            postNUI('appearance_set_camera', 'default');
        }
    }, true);

    // Clothes group (independent toggles, start active)
    const clothesGroup = createOptGroup(ICONS.shirt, [
        { icon: ICONS.hat, title: 'Head', key: 'head', active: true },
        { icon: ICONS.shirt, title: 'Body', key: 'body', active: true },
        { icon: ICONS.pants, title: 'Bottom', key: 'bottom', active: true },
    ], (key, btn) => {
        state.clothes[key] = !state.clothes[key];
        if (state.clothes[key]) {
            postNUI('appearance_wear_clothes', { data: state.data, key: key });
        } else {
            postNUI('appearance_remove_clothes', key);
        }
    }, false);

    // Turn around
    const turnBtn = createOptButton(ICONS.turnAround, 'Turn Around', () => {
        postNUI('appearance_turn_around');
    });

    // Rotate left/right
    const rotLeftBtn = createOptButton(ICONS.rotateLeft, 'Rotate Left', () => {
        postNUI('appearance_rotate_camera', 'left');
    });

    const rotRightBtn = createOptButton(ICONS.rotateRight, 'Rotate Right', () => {
        postNUI('appearance_rotate_camera', 'right');
    });

    // Save (uses uGen confirm modal via Lua)
    const saveBtn = createOptButton(ICONS.save, 'Save', () => {
        postNUI('appearance_request_save', state.data);
    });
    saveBtn.classList.add('save');

    // Exit (uses uGen confirm modal via Lua)
    const exitBtn = createOptButton(ICONS.exit, 'Exit', () => {
        postNUI('appearance_request_exit');
    });
    exitBtn.classList.add('exit');

    optionsBar.appendChild(cameraGroup);
    optionsBar.appendChild(clothesGroup);
    optionsBar.appendChild(turnBtn);
    optionsBar.appendChild(rotLeftBtn);
    optionsBar.appendChild(rotRightBtn);
    optionsBar.appendChild(saveBtn);
    if (state.config && state.config.allowExit) {
        optionsBar.appendChild(exitBtn);
    }
}

// ============================================
// Main UI Build
// ============================================

function buildUI() {
    panel.innerHTML = '';
    optionsBar.innerHTML = '';

    if (!state.config || !state.settings || !state.data) return;

    buildSections();
    buildOptionsBar();
}

function buildSections() {
    const cfg = state.config;
    const fm = isFreemode();

    // Ped Model
    if (cfg.ped) {
        panel.appendChild(buildPedSection());
    }

    // Genetics (freemode only)
    if (cfg.headBlend && fm) {
        const section = buildHeadBlendSection();
        if (section) panel.appendChild(section);
    }

    // Face Features (freemode only)
    if (cfg.faceFeatures && fm) {
        const section = buildFaceFeaturesSection();
        if (section) panel.appendChild(section);
    }

    // Hair (freemode only)
    if (cfg.headOverlays && fm) {
        const section = buildHairSection();
        if (section) panel.appendChild(section);
    }

    // Head Overlays (freemode only)
    if (cfg.headOverlays && fm) {
        const section = buildHeadOverlaysSection();
        if (section) panel.appendChild(section);
    }

    // Eye Color (freemode only)
    if (cfg.headOverlays && fm) {
        const section = buildEyeColorSection();
        if (section) panel.appendChild(section);
    }

    // Clothing (all peds)
    if (cfg.components) {
        panel.appendChild(buildComponentsSection());
    }

    // Props (all peds)
    if (cfg.props) {
        panel.appendChild(buildPropsSection());
    }

    // Tattoos (freemode only)
    if (cfg.tattoos && fm) {
        const section = buildTattoosSection();
        if (section) panel.appendChild(section);
    }
}

// ============================================
// NUI Message Handler
// ============================================
window.addEventListener('message', (event) => {
    const msg = event.data;

    switch (msg.type) {
        case 'appearance_display':
            container.classList.remove('hidden');
            postNUI('appearance_get_settings_and_data').then(result => {
                if (result) {
                    state.config = result.config;
                    state.settings = result.appearanceSettings;
                    state.data = result.appearanceData;
                    state.storedData = JSON.parse(JSON.stringify(result.appearanceData));
                    state.camera = { head: false, body: false, bottom: false };
                    state.rotate = { left: false, right: false };
                    state.clothes = { head: true, body: true, bottom: true };
                    buildUI();
                }
            });
            break;

        case 'appearance_hide':
            container.classList.add('hidden');
            panel.innerHTML = '';
            optionsBar.innerHTML = '';
            state.config = null;
            state.data = null;
            state.storedData = null;
            state.settings = null;
            break;
    }
});
