<!DOCTYPE html>
<html lang="en" data-theme="dark" data-ov="ui-sophisticated">
<head>
<meta name="application-name" content="HAWK-X">
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=5">
<title>HAWK-X | 3D Flight Command Simulator</title>
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700;800&family=JetBrains+Mono:wght@500;700;800&family=Orbitron:wght@600;800;900&family=Press+Start+2P&family=Space+Grotesk:wght@500;700&display=swap" rel="stylesheet">
<script src="https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js" crossorigin="anonymous"></script>
<style>
:root{
--bg:#07090F;--panel:#111522;--line:#263044;--text:#F8FAFC;--mute:#94A3B8;--plate:#181E2E;--accent:#D4AF37;
--deck1:#151B2B;--deck2:#0B0E17;--deck-border:#C5A059;
--font:"Inter",system-ui,-apple-system,"Segoe UI",Roboto,sans-serif;
--mono:"JetBrains Mono",ui-monospace,Menlo,Consolas,monospace;
box-sizing:border-box;color-scheme:dark
}
*{box-sizing:border-box;-webkit-tap-highlight-color:transparent;user-select:none}
*:focus-visible{outline:3px solid var(--accent,#D4AF37)!important;outline-offset:2px!important}
[hidden]{display:none!important}
body{margin:0;background:var(--bg);color:var(--text);font:500 13px/1.4 var(--font);min-height:100vh;overflow-x:hidden}
.wrap{max-width:1480px;margin:0 auto;padding:8px 10px;display:flex;flex-direction:column;gap:8px}
.bar{display:flex;flex-wrap:wrap;align-items:center;gap:7px;background:var(--panel);border:1px solid var(--line);border-radius:13px;padding:7px 10px}
button,select,input{font:inherit;color:var(--text);background:var(--panel);border:1px solid var(--line);border-radius:9px;padding:4px 8px;min-height:32px;cursor:pointer}
button:hover{filter:brightness(1.15)}
input[type=range]{padding:0;border:0;background:none;accent-color:var(--accent);min-height:auto}
input[type=color]{padding:1px;width:34px;height:28px;min-height:28px}
.brand{font-weight:800;font-size:15.5px;display:flex;align-items:center;gap:6px}.brand i{font-style:normal;color:var(--accent)}
.chip{font:700 11px var(--mono);padding:3px 8px;border-radius:7px;border:1px solid var(--line);color:var(--mute);display:inline-flex;align-items:center;gap:4px}
.seg{display:flex;flex-wrap:wrap;gap:2px;border:1px solid var(--line);border-radius:10px;padding:2px;background:rgba(0,0,0,0.25)}
.seg button,.seg a.nav-pill{display:inline-flex;align-items:center;justify-content:center;text-decoration:none;border:0;min-height:26px;padding:3px 8px;background:none;color:var(--mute);font-weight:700;font-size:11px;border-radius:7px;cursor:pointer}
.seg button[aria-pressed="true"],.seg button[aria-current="page"],.seg a.nav-pill[aria-current="page"]{background:var(--accent);color:#04121C}
.deck{display:flex;flex-direction:column;gap:9px;background:linear-gradient(145deg,var(--deck1),var(--deck2));border:2px solid var(--deck-border);border-radius:16px;padding:11px}
.subcard{background:rgba(0,0,0,0.28);border:1px solid var(--line);border-radius:10px;padding:8px 10px;width:100%;display:flex;flex-wrap:wrap;align-items:center;gap:7px}
.subhead{font:800 10.5px var(--mono);text-transform:uppercase;color:var(--accent);letter-spacing:0.5px;margin-right:4px}
.swatch-pill{display:inline-flex;align-items:center;gap:6px;padding:3px 9px;border-radius:8px;border:2px solid #fff;font:800 12px var(--mono);box-shadow:0 0 12px var(--active-c,#00F5D4)}

/* === 13 UI THEMES === */
:root[data-theme="dark"]{--bg:#07090E!important;--panel:#12141A!important;--line:#262A34!important;--text:#F1F5F9!important;--mute:#94A3B8!important;--plate:#181D2A!important;--deck1:#161B26!important;--deck2:#0C0F17!important;--deck-border:#C5A059!important}
:root[data-theme="light"]{--bg:#E8EBF0!important;--panel:#F8FAFC!important;--line:#CBD5E1!important;--text:#0F172A!important;--mute:#475569!important;--plate:#CBD5E1!important;--deck1:#F1F5F9!important;--deck2:#E2E8F0!important;--deck-border:#64748B!important;color-scheme:light}
:root[data-theme="matrix"]{--bg:#010902!important;--panel:#031606!important;--line:#00FF41!important;--text:#00FF41!important;--mute:#22C55E!important;--plate:#042409!important;--accent:#00FF41!important;--deck1:#031A07!important;--deck2:#010802!important;--deck-border:#00FF41!important}
:root[data-theme="cyberpunk"]{--bg:#0D0221!important;--panel:#19053B!important;--line:#FF007F!important;--text:#F0ABFC!important;--mute:#C084FC!important;--plate:#2E1065!important;--accent:#00F0FF!important;--deck1:#240046!important;--deck2:#10002B!important;--deck-border:#FF007F!important}

/* === HAWK-X 3D WEBGL STAGE & HUD === */
.hawkx-stage-wrap {
  position: relative;
  border-radius: 16px;
  overflow: hidden;
  border: 2px solid #00F5D4;
  background: #020610;
  box-shadow: 0 22px 60px rgba(0,0,0,0.92), 0 0 28px rgba(0,245,212,0.22);
}
#hawkxViewport {
  position: relative;
  width: 100%;
  height: clamp(500px, 68dvh, 780px);
  overflow: hidden;
  background: #02050D;
}
#hawkx3dCanvas {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  display: block;
  z-index: 1;
}
#hawkxCanvas {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  display: block;
  z-index: 2;
  pointer-events: auto;
  cursor: crosshair;
  touch-action: none;
}

/* Gunship Turret FLIR Visual Filter Modes on 3D Canvas */
#hawkx3dCanvas.flir-whot { filter: grayscale(100%) contrast(185%) brightness(115%); }
#hawkx3dCanvas.flir-bhot { filter: grayscale(100%) invert(100%) contrast(175%); }
#hawkx3dCanvas.flir-nvg  { filter: sepia(100%) hue-rotate(75deg) saturate(360%) contrast(155%) brightness(95%); }

/* Dedicated Left & Right Edge LB/RB Rudder Turning Buttons */
.rudder-edge-btn {
  position: absolute;
  top: 46%;
  transform: translateY(-50%);
  z-index: 9;
  width: 44px;
  height: 112px;
  border-radius: 12px;
  background: rgba(6, 14, 28, 0.72);
  backdrop-filter: blur(6px);
  border: 1.5px solid rgba(0, 245, 212, 0.55);
  color: #00F5D4;
  font: 900 10px "Orbitron", var(--mono);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 4px;
  writing-mode: vertical-rl;
  text-orientation: mixed;
  cursor: pointer;
  pointer-events: auto;
  box-shadow: 0 0 18px rgba(0, 245, 212, 0.2);
}
.rudder-edge-btn.left { left: 6px; }
.rudder-edge-btn.right { right: 6px; }
.rudder-edge-btn:active {
  background: rgba(0, 245, 212, 0.85);
  color: #04121C;
}

/* Incoming Enemy Missile Lock-On Alert Banner + Countdown to Impact */
#incomingMissileBanner {
  position: absolute;
  top: 46px;
  left: 50%;
  transform: translateX(-50%);
  z-index: 15;
  background: linear-gradient(90deg, rgba(153, 27, 27, 0.94), rgba(220, 38, 38, 0.94));
  border: 2px solid #FACC15;
  border-radius: 12px;
  padding: 5px 14px;
  font: 900 11.5px "Orbitron", var(--mono);
  color: #FFFFFF;
  box-shadow: 0 0 28px rgba(239, 68, 68, 0.85);
  pointer-events: none;
  animation: mslPulse 0.32s infinite alternate;
}
@keyframes mslPulse {
  from { transform: translateX(-50%) scale(1.0); }
  to   { transform: translateX(-50%) scale(1.04); }
}

.hx-hud-top {
  position: absolute;
  top: 8px;
  left: 8px;
  right: 8px;
  z-index: 8;
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  flex-wrap: wrap;
  gap: 6px;
  pointer-events: none;
}
.hx-hud-bottom {
  position: absolute;
  bottom: 8px;
  left: 8px;
  right: 8px;
  z-index: 8;
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
  flex-wrap: wrap;
  gap: 6px;
  pointer-events: none;
}
.hx-pill {
  pointer-events: auto;
  background: rgba(5, 10, 20, 0.84);
  backdrop-filter: blur(8px);
  border: 1.5px solid rgba(0, 245, 212, 0.45);
  border-radius: 11px;
  padding: 5px 10px;
  font: 800 11px var(--mono);
  color: #F8FAFC;
  display: flex;
  align-items: center;
  gap: 6px;
  flex-wrap: wrap;
}

#beaconPromptModal {
  position: absolute;
  top: 82px;
  left: 50%;
  transform: translateX(-50%);
  z-index: 10;
  background: linear-gradient(135deg, rgba(9, 14, 28, 0.96), rgba(88, 28, 135, 0.92));
  border: 2px solid #00F5D4;
  border-radius: 14px;
  padding: 8px 15px;
  display: flex;
  align-items: center;
  gap: 10px;
  box-shadow: 0 0 32px rgba(0, 245, 212, 0.55);
  font: 800 11.5px var(--mono);
}

#satBriefingModal {
  position: absolute;
  bottom: 66px;
  left: 50%;
  transform: translateX(-50%);
  z-index: 14;
  width: min(620px, 95vw);
  background: linear-gradient(145deg, rgba(5, 11, 22, 0.96), rgba(15, 23, 42, 0.97));
  border: 2.5px solid #D4AF37;
  border-radius: 16px;
  padding: 13px 16px;
  box-shadow: 0 0 55px rgba(212, 175, 55, 0.45);
  pointer-events: auto;
  font: 700 11px var(--mono);
}

#commanderHudPanel {
  position: absolute;
  top: 88px;
  left: 56px;
  right: 56px;
  z-index: 13;
  background: linear-gradient(135deg, rgba(4, 14, 28, 0.92), rgba(15, 23, 42, 0.92));
  border: 2px solid #00F5D4;
  border-radius: 14px;
  padding: 9px 12px;
  display: flex;
  flex-direction: column;
  gap: 7px;
  pointer-events: auto;
  font: 700 11px var(--mono);
  box-shadow: 0 0 40px rgba(0, 245, 212, 0.35);
}

#missionBannerToast {
  position: absolute;
  top: 38%;
  left: 50%;
  transform: translate(-50%, -50%);
  z-index: 16;
  background: linear-gradient(135deg, rgba(6, 78, 59, 0.96), rgba(15, 23, 42, 0.96));
  border: 2.5px solid #FACC15;
  border-radius: 16px;
  padding: 16px 26px;
  text-align: center;
  box-shadow: 0 0 50px rgba(250, 204, 21, 0.65);
  pointer-events: auto;
}

.touch-combat-pad {
  display: flex;
  gap: 4px;
  flex-wrap: wrap;
  align-items: center;
}
.combat-btn {
  padding: 5px 8px;
  border-radius: 8px;
  font: 900 10px "Orbitron", var(--mono);
  border: 1.5px solid rgba(255,255,255,0.28);
  color: #FFF;
  cursor: pointer;
  user-select: none;
  min-height: 29px;
}
.combat-btn:active { transform: scale(0.95); }

.campaign-stage-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(235px, 1fr));
  gap: 8px;
  width: 100%;
}
.dossier-card {
  background: rgba(9, 14, 26, 0.94);
  border: 1.5px solid var(--line);
  border-radius: 11px;
  padding: 8px 10px;
  display: flex;
  flex-direction: column;
  gap: 4px;
  font: 700 10.5px var(--mono);
}
.dossier-card.completed {
  border-color: #10B981;
  background: linear-gradient(135deg, rgba(6,78,59,0.28), rgba(9,14,26,0.95));
}
.dossier-card.locked {
  opacity: 0.55;
  border-style: dashed;
}

#customizerStudioModal,
#controlsMapModal {
  position: fixed;
  inset: 0;
  z-index: 9990;
  background: radial-gradient(circle at 50% 25%, #0F172A 0%, #03060E 90%);
  display: flex;
  flex-direction: column;
  gap: 10px;
  padding: 14px;
  overflow-y: auto;
}
#customizerStudioModal[hidden],
#controlsMapModal[hidden] { display: none !important; }
.cust-studio-grid {
  display: grid;
  grid-template-columns: 1.2fr 1fr;
  gap: 12px;
  flex: 1;
}
.hx-side-dock {
  position: absolute;
  top: 52%;
  transform: translateY(-50%);
  z-index: 12;
  display: flex;
  flex-direction: column;
  gap: 3px;
  background: rgba(4, 10, 20, 0.78);
  backdrop-filter: blur(8px);
  border: 1.5px solid rgba(0, 245, 212, 0.42);
  border-radius: 12px;
  padding: 5px;
  width: 112px;
  max-height: 82%;
  overflow-y: auto;
  pointer-events: auto;
  box-shadow: 0 0 24px rgba(0, 0, 0, 0.65);
  transition: opacity 0.18s, transform 0.18s;
}
.hx-side-dock.left-dock { left: 6px; border-left: 3px solid #00F5D4; }
.hx-side-dock.right-dock { right: 6px; border-right: 3px solid #FACC15; }
.hx-side-dock .side-dock-hdr {
  font: 900 8.5px "Orbitron", var(--mono);
  text-align: center;
  letter-spacing: 0.04em;
  padding-bottom: 2px;
  border-bottom: 1px solid rgba(255,255,255,0.14);
  color: #38BDF8;
}
.hx-side-btn {
  width: 100%;
  padding: 4px 5px;
  border-radius: 7px;
  font: 800 9px "Orbitron", var(--mono);
  border: 1px solid rgba(255,255,255,0.22);
  background: rgba(15, 23, 42, 0.88);
  color: #F8FAFC;
  cursor: pointer;
  text-align: left;
  display: flex;
  align-items: center;
  justify-content: space-between;
  min-height: 24px;
  user-select: none;
  white-space: nowrap;
}
.hx-side-btn:hover { border-color: #00F5D4; background: rgba(14, 116, 144, 0.45); }
.hx-side-btn:active { transform: scale(0.96); }
#hawkxViewport.hx-hide-side-docks .hx-side-dock {
  display: none !important;
}

#preTakeoffPlanningBar {
  position: absolute;
  bottom: 58px;
  left: 50%;
  transform: translateX(-50%);
  z-index: 15;
  width: min(780px, 92vw);
  background: linear-gradient(145deg, rgba(4, 12, 24, 0.96), rgba(6, 78, 59, 0.92));
  border: 2.5px solid #00F5D4;
  border-radius: 15px;
  padding: 10px 14px;
  box-shadow: 0 0 48px rgba(0, 245, 212, 0.45);
  pointer-events: auto;
  font: 700 11px var(--mono);
}
#preTakeoffPlanningBar[hidden] { display: none !important; }

#hawkxViewport.hx-hide-bottom-pad .hx-hud-bottom {
  display: none !important;
}
#hawkxViewport.hx-hide-top-menu .hx-hud-top > .hx-pill:not(#minimalCleanHudPill) {
  display: none !important;
}
body.hx-fs .hx-hud-bottom,
.hawkx-stage-wrap:fullscreen .hx-hud-bottom {
  display: none !important;
}
body.hx-fs .rudder-edge-btn,
.hawkx-stage-wrap:fullscreen .rudder-edge-btn {
  display: none !important;
}
#minimalCleanHudPill {
  margin-left: auto;
  background: rgba(4, 9, 18, 0.72);
  border-color: rgba(0, 245, 212, 0.45);
  padding: 3px 8px;
  gap: 5px;
}

@media (max-width: 960px) {
  .cust-studio-grid { grid-template-columns: 1fr; }
}
#customizer3dPreviewCanvas {
  width: 100%;
  height: clamp(320px, 52dvh, 520px);
  background: radial-gradient(circle at 50% 55%, #111C35 0%, #040710 85%);
  border: 2px solid #00F5D4;
  border-radius: 14px;
  display: block;
  cursor: grab;
}

.hx-grid-2col {
  display: grid;
  grid-template-columns: 1.38fr 1fr;
  gap: 10px;
}
@media (max-width: 1020px) {
  .hx-grid-2col { grid-template-columns: 1fr; }
}
.jet-shop-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(195px, 1fr));
  gap: 8px;
  width: 100%;
}
.jet-card {
  background: rgba(10, 15, 28, 0.94);
  border: 1.5px solid var(--line);
  border-radius: 12px;
  padding: 8px 9px;
  display: flex;
  flex-direction: column;
  gap: 5px;
  font: 700 10.5px var(--mono);
  transition: border-color 0.14s, box-shadow 0.14s;
}
.jet-card.active-jet {
  border-color: #00F5D4;
  box-shadow: 0 0 22px rgba(0, 245, 212, 0.35);
  background: linear-gradient(135deg, rgba(15,23,42,0.96), rgba(0,245,212,0.14));
}
.jet-thumb-cv {
  width: 100%;
  height: 104px;
  background: radial-gradient(circle at 50% 50%, #172542 0%, #050811 92%);
  border-radius: 8px;
  border: 1px solid rgba(0,245,212,0.28);
  display: block;
}
.stat-bar-bg {
  width: 100%;
  height: 5px;
  background: #050811;
  border-radius: 3px;
  overflow: hidden;
  border: 1px solid rgba(255,255,255,0.12);
}
.stat-bar-fill {
  height: 100%;
  background: linear-gradient(90deg, #00F5D4, #38BDF8, #D4AF37);
}
.upgrade-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 8px;
  padding: 7px 10px;
  border-radius: 10px;
  background: rgba(255,255,255,0.03);
  border: 1px solid var(--line);
  font: 700 11px var(--mono);
  width: 100%;
}
.lvl-pip {
  display: inline-block;
  width: 14px;
  height: 8px;
  border-radius: 2px;
  margin-right: 2px;
  background: #1E293B;
  border: 1px solid #475569;
}
.lvl-pip.on {
  background: #00F5D4;
  border-color: #FFF;
  box-shadow: 0 0 6px #00F5D4;
}

.keymap-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 10px;
  width: 100%;
}
@media (max-width: 900px) {
  .keymap-grid { grid-template-columns: 1fr; }
}
.kcap {
  display: inline-flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-width: 48px;
  padding: 5px 8px;
  border-radius: 8px;
  background: #0B1120;
  border: 1.5px solid #334155;
  box-shadow: 0 3px 0 #1E293B;
  font: 800 10.5px var(--mono);
  color: #E2E8F0;
  transition: all 0.08s;
}
.kcap small {
  font-size: 9px;
  color: #38BDF8;
  font-weight: 700;
}
.kcap.active-key {
  background: #00F5D4 !important;
  color: #04121C !important;
  border-color: #FFF !important;
  box-shadow: 0 0 16px #00F5D4 !important;
  transform: translateY(2px);
}
.kcap.active-key small { color: #04121C !important; }

body.hx-fs header,
body.hx-fs #sharedCustPanel,
body.hx-fs .hx-controls-area {
  display: none !important;
}
body.hx-fs .wrap {
  max-width: 100vw !important;
  width: 100vw !important;
  height: 100dvh !important;
  padding: 0 !important;
  margin: 0 !important;
}
body.hx-fs .hawkx-stage-wrap,
.hawkx-stage-wrap:fullscreen,
.hawkx-stage-wrap:-webkit-full-screen {
  border: none !important;
  border-radius: 0 !important;
  width: 100vw !important;
  height: 100dvh !important;
  max-height: 100dvh !important;
}
body.hx-fs #hawkxViewport,
.hawkx-stage-wrap:fullscreen #hawkxViewport,
.hawkx-stage-wrap:-webkit-full-screen #hawkxViewport {
  width: 100vw !important;
  height: 100dvh !important;
  max-height: 100dvh !important;
}

body.hx-fs .fs-hide,
.hawkx-stage-wrap:fullscreen .fs-hide,
.hawkx-stage-wrap:-webkit-full-screen .fs-hide {
  display: none !important;
}
body.hx-fs #hudMissionBarPill:not(.fs-drawer-open),
.hawkx-stage-wrap:fullscreen #hudMissionBarPill:not(.fs-drawer-open) {
  display: none !important;
}
body.hx-fs .hx-hud-top,
.hawkx-stage-wrap:fullscreen .hx-hud-top {
  top: 4px;
  left: 6px;
  right: 6px;
  gap: 4px;
}
body.hx-fs .hx-hud-bottom,
.hawkx-stage-wrap:fullscreen .hx-hud-bottom {
  bottom: 6px;
  left: 6px;
  right: 6px;
  gap: 4px;
}
body.hx-fs .hx-pill,
.hawkx-stage-wrap:fullscreen .hx-pill {
  padding: 3px 7px;
  font-size: 10px;
  background: rgba(4, 8, 16, 0.65);
  border-color: rgba(0, 245, 212, 0.32);
}
body.hx-fs .combat-btn,
.hawkx-stage-wrap:fullscreen .combat-btn {
  padding: 4px 7px;
  font-size: 9.5px;
  min-height: 27px;
  background-color: rgba(15, 23, 42, 0.72);
}

@media (max-width: 960px) {
  .fs-hide { display: none !important; }
  #hawkxViewport { height: clamp(420px, 74dvh, 720px); }
  .hx-pill { padding: 3px 6px; font-size: 9.5px; gap: 4px; }
  .combat-btn { padding: 4px 6px; font-size: 9px; min-height: 26px; border-radius: 7px; }
  .touch-combat-pad { gap: 3px; justify-content: center; width: 100%; }
  #hudMissionBarPill:not(.fs-drawer-open) { display: none !important; }
  .rudder-edge-btn { width: 34px; height: 92px; font-size: 8.5px; }
}

.hx-product-header{position:relative;z-index:30;min-height:62px;padding:9px 14px;border-color:rgba(0,245,212,.34);background:linear-gradient(110deg,#0a1220,#101b2c 58%,#111827)}
.hx-brand-lockup,.hx-header-actions{display:flex;align-items:center;gap:12px;flex-wrap:wrap}
.hx-brand-mark{font-size:28px;filter:drop-shadow(0 0 10px rgba(0,245,212,.45))}
.hx-brand-name{font:900 21px "Orbitron",var(--mono);letter-spacing:.12em;color:#f8fafc;line-height:1.05}
.hx-brand-name span{color:#00f5d4}
.hx-brand-subtitle{font:700 8px var(--mono);letter-spacing:.2em;color:#94a3b8;margin-top:4px}
.hx-product-chip{color:#00f5d4;border-color:rgba(0,245,212,.3)}
.hx-header-actions button{min-height:38px;padding:7px 11px;font-weight:800}
.hx-accent-button{background:linear-gradient(120deg,#00f5d4,#38bdf8);color:#04121c;border-color:transparent;font-weight:900}
#sharedCustPanel{display:none!important}
.wrap{max-width:1720px;gap:10px;padding:10px 12px}
.hawkx-stage-wrap{border-color:rgba(0,245,212,.65);box-shadow:0 18px 55px rgba(0,0,0,.55),0 0 22px rgba(0,245,212,.12)}
#hawkxViewport{height:clamp(540px,76dvh,900px);min-height:420px}
#hxFullscreenBtn.hx-top-fullscreen{position:relative!important;z-index:10030!important;flex:0 0 auto;min-height:38px!important;padding:8px 13px!important;margin:0 0 0 2px!important;border:1px solid #00f5d4!important;border-radius:10px!important;background:linear-gradient(135deg,#00f5d4,#38bdf8)!important;color:#04121c!important;font:900 11px "Orbitron",var(--mono)!important;box-shadow:0 4px 16px rgba(0,0,0,.35),0 0 12px rgba(0,245,212,.2)!important;white-space:nowrap}
#hxFullscreenBtn.hx-top-fullscreen:hov
