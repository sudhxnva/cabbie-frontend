// App.tsx
import { useState, useEffect, useRef, useCallback } from "react";
import { useConversation } from "@elevenlabs/react";

const AGENT_ID = import.meta.env.VITE_ELEVENLABS_AGENT_ID || "agent_9001kk5mjgwdf8v8b92a0tnnzmn8";
const BACKEND_URL = import.meta.env.VITE_BACKEND_URL || "http://localhost:3001";

const css = `
  @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Syne:wght@700;800&display=swap');

  *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

  :root {
    --bg: #0d0d12;
    --bg2: #13131a;
    --surface: rgba(255,255,255,0.055);
    --surface-hover: rgba(255,255,255,0.09);
    --border: rgba(255,255,255,0.08);
    --border-bright: rgba(255,255,255,0.18);
    --text: #f0f0f5;
    --text-muted: rgba(240,240,245,0.45);
    --text-sub: rgba(240,240,245,0.65);
    --accent: #7c6dfa;
    --accent2: #a78bfa;
    --green: #34d399;
    --green-dim: rgba(52,211,153,0.12);
    --red: #f87171;
    --amber: #fbbf24;
    --radius: 20px;
    --radius-sm: 14px;
    --radius-xs: 10px;
    --font: 'Inter', system-ui, sans-serif;
    --font-display: 'Syne', sans-serif;
    --shadow-glow: 0 0 40px rgba(124,109,250,0.15);
    --transition: 0.2s cubic-bezier(0.4,0,0.2,1);
  }

  html, body {
    height: 100%;
    width: 100%;
    font-family: var(--font);
    background: var(--bg);
    color: var(--text);
    -webkit-font-smoothing: antialiased;
    overflow-x: hidden;
    display: flex;
    justify-content: center;
  }

  /* ── Animated background ── */
  body::before {
    content: '';
    position: fixed;
    inset: 0;
    background:
      radial-gradient(ellipse 80% 60% at 20% 0%, rgba(124,109,250,0.12) 0%, transparent 60%),
      radial-gradient(ellipse 60% 40% at 80% 100%, rgba(167,139,250,0.08) 0%, transparent 55%);
    pointer-events: none;
    z-index: 0;
  }

  #root { position: relative; z-index: 1; }

  .app {
    max-width: 430px;
    min-height: 100dvh;
    margin: 0 auto;
    display: flex;
    flex-direction: column;
    padding: 0 0 env(safe-area-inset-bottom, 24px);
  }

  /* ── Header ── */
  .header {
    padding: 56px 24px 20px;
    position: relative;
  }
  .header-pill {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 4px 12px;
    border-radius: 99px;
    border: 1px solid var(--border-bright);
    background: var(--surface);
    font-size: 11px;
    font-weight: 600;
    letter-spacing: 0.12em;
    text-transform: uppercase;
    color: var(--accent2);
    margin-bottom: 14px;
  }
  .header-pill-dot {
    width: 6px; height: 6px;
    border-radius: 50%;
    background: var(--green);
    box-shadow: 0 0 6px var(--green);
    animation: pulse-dot 2s ease-in-out infinite;
  }
  @keyframes pulse-dot {
    0%,100% { opacity: 1; }
    50%      { opacity: 0.4; }
  }
  .header-title {
    font-family: var(--font-display);
    font-size: 42px;
    font-weight: 800;
    line-height: 1;
    letter-spacing: -0.02em;
    background: linear-gradient(135deg, #fff 30%, var(--accent2) 100%);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
    margin-bottom: 6px;
  }
  .header-sub {
    font-size: 14px;
    color: var(--text-muted);
    font-weight: 400;
  }

  /* ── Voice section ── */
  .voice-section {
    padding: 28px 24px 20px;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 20px;
  }

  .voice-ring {
    position: relative;
    width: 120px;
    height: 120px;
  }
  .voice-ring-bg {
    position: absolute;
    inset: -12px;
    border-radius: 50%;
    border: 1px solid var(--border);
    animation: spin-slow 8s linear infinite;
    background: conic-gradient(transparent 70%, rgba(124,109,250,0.3) 100%);
  }
  @keyframes spin-slow {
    to { transform: rotate(360deg); }
  }

  .voice-btn {
    width: 120px;
    height: 120px;
    border-radius: 50%;
    border: none;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    position: relative;
    outline: none;
    transition: transform var(--transition), box-shadow var(--transition);
    z-index: 1;
  }
  .voice-btn:active { transform: scale(0.93) !important; }

  .voice-btn.idle {
    background: linear-gradient(145deg, #1e1b3a, #2d2060);
    box-shadow: 0 0 0 1px var(--border-bright), var(--shadow-glow), 0 16px 40px rgba(0,0,0,0.5);
  }
  .voice-btn.idle:hover {
    transform: scale(1.05);
    box-shadow: 0 0 0 1px var(--border-bright), 0 0 60px rgba(124,109,250,0.3), 0 20px 50px rgba(0,0,0,0.5);
  }
  .voice-btn.connected {
    background: linear-gradient(145deg, #3b0f0f, #7f1d1d);
    box-shadow: 0 0 0 1px rgba(248,113,113,0.3), 0 0 50px rgba(248,113,113,0.2), 0 16px 40px rgba(0,0,0,0.5);
    animation: breathe 2s ease-in-out infinite;
  }
  .voice-btn.connecting {
    background: linear-gradient(145deg, #1a1a2e, #16213e);
    box-shadow: 0 0 0 1px var(--border);
  }

  @keyframes breathe {
    0%,100% { box-shadow: 0 0 0 1px rgba(248,113,113,0.3), 0 0 30px rgba(248,113,113,0.15), 0 16px 40px rgba(0,0,0,0.5); }
    50%      { box-shadow: 0 0 0 1px rgba(248,113,113,0.5), 0 0 60px rgba(248,113,113,0.3), 0 16px 40px rgba(0,0,0,0.5); }
  }

  .voice-btn svg { pointer-events: none; }

  .voice-label {
    font-size: 13px;
    font-weight: 500;
    color: var(--text-muted);
    letter-spacing: 0.03em;
    text-align: center;
  }

  /* ── Speaking waveform ── */
  .speaking-indicator {
    display: flex;
    align-items: center;
    gap: 3px;
    height: 20px;
  }
  .speaking-indicator span {
    display: block;
    width: 3px;
    border-radius: 99px;
    background: linear-gradient(to top, var(--accent), var(--accent2));
    animation: wave 0.9s ease-in-out infinite;
  }
  .speaking-indicator span:nth-child(1) { height: 8px;  animation-delay: 0s; }
  .speaking-indicator span:nth-child(2) { height: 18px; animation-delay: 0.1s; }
  .speaking-indicator span:nth-child(3) { height: 12px; animation-delay: 0.2s; }
  .speaking-indicator span:nth-child(4) { height: 20px; animation-delay: 0.15s; }
  .speaking-indicator span:nth-child(5) { height: 10px; animation-delay: 0.05s; }

  @keyframes wave {
    0%,100% { transform: scaleY(0.4); opacity: 0.5; }
    50%      { transform: scaleY(1);   opacity: 1; }
  }

  /* ── Divider ── */
  .divider {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 0 24px;
    margin: 4px 0;
  }
  .divider::before, .divider::after {
    content: '';
    flex: 1;
    height: 1px;
    background: var(--border);
  }
  .divider span {
    font-size: 11px;
    color: var(--text-muted);
    letter-spacing: 0.08em;
    text-transform: uppercase;
    font-weight: 500;
  }

  /* ── Text input ── */
  .text-section {
    padding: 12px 24px 0;
    display: flex;
    gap: 10px;
  }
  .text-input {
    flex: 1;
    padding: 14px 18px;
    border: 1px solid var(--border);
    border-radius: var(--radius-sm);
    font-family: var(--font);
    font-size: 14px;
    color: var(--text);
    background: var(--surface);
    outline: none;
    transition: border-color var(--transition), background var(--transition), box-shadow var(--transition);
    backdrop-filter: blur(12px);
    -webkit-backdrop-filter: blur(12px);
  }
  .text-input:focus {
    border-color: var(--accent);
    background: var(--surface-hover);
    box-shadow: 0 0 0 3px rgba(124,109,250,0.12);
  }
  .text-input::placeholder { color: var(--text-muted); }

  .send-btn {
    padding: 14px 20px;
    border-radius: var(--radius-sm);
    border: none;
    background: linear-gradient(135deg, var(--accent), var(--accent2));
    color: #fff;
    font-family: var(--font);
    font-size: 13px;
    font-weight: 600;
    cursor: pointer;
    transition: opacity var(--transition), transform var(--transition);
    white-space: nowrap;
    box-shadow: 0 4px 16px rgba(124,109,250,0.3);
  }
  .send-btn:hover { opacity: 0.88; transform: translateY(-1px); }
  .send-btn:active { transform: translateY(0); }

  /* ── Status bar ── */
  .status-bar {
    margin: 20px 24px 0;
    padding: 14px 18px;
    border-radius: var(--radius-sm);
    background: var(--surface);
    border: 1px solid var(--border);
    backdrop-filter: blur(12px);
    -webkit-backdrop-filter: blur(12px);
    display: flex;
    align-items: center;
    gap: 12px;
    min-height: 50px;
  }
  .status-dot {
    width: 8px; height: 8px;
    border-radius: 50%;
    flex-shrink: 0;
    transition: background var(--transition), box-shadow var(--transition);
  }
  .status-dot.idle      { background: var(--text-muted); }
  .status-dot.searching { background: var(--amber); box-shadow: 0 0 8px var(--amber); animation: blink 1s ease-in-out infinite; }
  .status-dot.ready     { background: var(--green); box-shadow: 0 0 8px var(--green); }
  .status-dot.confirmed { background: var(--green); box-shadow: 0 0 8px var(--green); }
  .status-dot.error     { background: var(--red); box-shadow: 0 0 8px var(--red); }

  @keyframes blink {
    0%,100% { opacity: 1; }
    50%      { opacity: 0.25; }
  }

  .status-text {
    font-size: 13px;
    color: var(--text-sub);
    line-height: 1.45;
    font-weight: 400;
  }

  /* ── Options section ── */
  .options-section {
    padding: 24px 24px 0;
    animation: slide-up 0.35s cubic-bezier(0.22,1,0.36,1);
  }
  @keyframes slide-up {
    from { opacity: 0; transform: translateY(20px); }
    to   { opacity: 1; transform: translateY(0); }
  }

  .options-label {
    font-size: 11px;
    font-weight: 600;
    letter-spacing: 0.12em;
    text-transform: uppercase;
    color: var(--text-muted);
    margin-bottom: 14px;
  }

  .option-card {
    border: 1px solid var(--border);
    border-radius: var(--radius);
    padding: 18px;
    margin-bottom: 10px;
    cursor: pointer;
    transition: border-color var(--transition), box-shadow var(--transition), transform var(--transition), background var(--transition);
    background: var(--surface);
    backdrop-filter: blur(12px);
    -webkit-backdrop-filter: blur(12px);
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 14px;
  }
  .option-card:hover {
    border-color: var(--accent);
    box-shadow: 0 0 0 1px rgba(124,109,250,0.15), 0 8px 24px rgba(0,0,0,0.3);
    transform: translateY(-2px);
    background: var(--surface-hover);
  }
  .option-card.selected {
    border-color: var(--accent);
    background: linear-gradient(135deg, rgba(124,109,250,0.18), rgba(167,139,250,0.1));
    box-shadow: 0 0 0 1px rgba(124,109,250,0.4), 0 8px 30px rgba(124,109,250,0.15);
    transform: translateY(-2px);
  }

  .option-left { display: flex; align-items: center; gap: 14px; flex: 1; min-width: 0; }

  .option-rank {
    width: 36px; height: 36px;
    border-radius: 10px;
    background: rgba(255,255,255,0.06);
    border: 1px solid var(--border);
    display: flex; align-items: center; justify-content: center;
    font-size: 13px;
    font-weight: 700;
    color: var(--text-sub);
    flex-shrink: 0;
  }
  .option-card.selected .option-rank {
    background: rgba(124,109,250,0.2);
    border-color: rgba(124,109,250,0.4);
    color: var(--accent2);
  }

  .option-name {
    font-size: 15px;
    font-weight: 600;
    margin-bottom: 3px;
    color: var(--text);
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }
  .option-meta {
    font-size: 12px;
    color: var(--text-muted);
    font-weight: 400;
  }

  .option-right { text-align: right; flex-shrink: 0; }
  .option-price {
    font-family: var(--font-display);
    font-size: 22px;
    font-weight: 700;
    line-height: 1;
    margin-bottom: 3px;
    background: linear-gradient(135deg, #fff, var(--accent2));
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
  }
  .option-eta {
    font-size: 12px;
    color: var(--text-muted);
  }

  .book-btn {
    width: 100%;
    margin-top: 14px;
    padding: 16px;
    border-radius: var(--radius-sm);
    border: none;
    background: linear-gradient(135deg, var(--accent), var(--accent2));
    color: #fff;
    font-family: var(--font);
    font-size: 15px;
    font-weight: 600;
    cursor: pointer;
    transition: opacity var(--transition), transform var(--transition), box-shadow var(--transition);
    letter-spacing: 0.01em;
    box-shadow: 0 6px 24px rgba(124,109,250,0.35);
  }
  .book-btn:hover:not(:disabled) {
    opacity: 0.9;
    transform: translateY(-1px);
    box-shadow: 0 10px 32px rgba(124,109,250,0.45);
  }
  .book-btn:disabled { opacity: 0.28; cursor: not-allowed; box-shadow: none; }

  /* ── Confirmation ── */
  .confirmation {
    margin: 24px;
    padding: 36px 28px;
    border-radius: var(--radius);
    background: linear-gradient(135deg, rgba(52,211,153,0.1), rgba(52,211,153,0.04));
    border: 1px solid rgba(52,211,153,0.25);
    backdrop-filter: blur(16px);
    -webkit-backdrop-filter: blur(16px);
    animation: slide-up 0.4s cubic-bezier(0.22,1,0.36,1);
    text-align: center;
  }
  .confirmation-check {
    width: 64px; height: 64px;
    border-radius: 50%;
    background: var(--green-dim);
    border: 1px solid rgba(52,211,153,0.3);
    display: flex; align-items: center; justify-content: center;
    margin: 0 auto 18px;
    font-size: 28px;
  }
  .confirmation-ref {
    font-family: var(--font-display);
    font-size: 30px;
    font-weight: 800;
    letter-spacing: 0.06em;
    color: var(--green);
    margin-bottom: 8px;
  }
  .confirmation-details {
    font-size: 14px;
    color: var(--text-sub);
    margin-bottom: 28px;
    line-height: 1.6;
  }
  .new-booking-btn {
    padding: 13px 28px;
    border-radius: var(--radius-xs);
    border: 1px solid rgba(52,211,153,0.35);
    background: transparent;
    color: var(--green);
    font-family: var(--font);
    font-size: 14px;
    font-weight: 600;
    cursor: pointer;
    transition: background var(--transition), color var(--transition), box-shadow var(--transition);
  }
  .new-booking-btn:hover {
    background: var(--green);
    color: #0d0d12;
    box-shadow: 0 6px 20px rgba(52,211,153,0.3);
  }

  /* ── Hint ── */
  .hint {
    padding: 0 32px;
    margin-top: 20px;
    font-size: 13px;
    color: var(--text-muted);
    text-align: center;
    line-height: 1.6;
    font-weight: 400;
  }

  /* ── Spinner ── */
  @keyframes spin { to { transform: rotate(360deg); } }
  .spinner { animation: spin 0.75s linear infinite; transform-origin: center; }
`;

// ── Icons ──────────────────────────────────────────────────────────────────
const MicIcon = ({ size = 30 }: { size?: number }) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
    <path d="M12 2a3 3 0 0 1 3 3v7a3 3 0 0 1-6 0V5a3 3 0 0 1 3-3z" />
    <path d="M19 10v2a7 7 0 0 1-14 0v-2" />
    <line x1="12" y1="19" x2="12" y2="22" />
    <line x1="8" y1="22" x2="16" y2="22" />
  </svg>
);

const StopIcon = ({ size = 26 }: { size?: number }) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill="rgba(255,255,255,0.9)">
    <rect x="6" y="6" width="12" height="12" rx="3" />
  </svg>
);

const SpinnerIcon = () => (
  <svg className="spinner" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,0.5)" strokeWidth="2.5" strokeLinecap="round">
    <path d="M12 2v4M12 18v4M4.93 4.93l2.83 2.83M16.24 16.24l2.83 2.83M2 12h4M18 12h4M4.93 19.07l2.83-2.83M16.24 7.76l2.83-2.83" />
  </svg>
);

// ── Main Component ──────────────────────────────────────────────────────────
export default function App() {
  const [phase, setPhase] = useState("idle");
  const [statusMsg, setStatusMsg] = useState("Tap the mic or type your destination");
  const [options, setOptions] = useState<any[]>([]);
  const [selectedId, setSelectedId] = useState<string | null>(null);
  const [booking, setBooking] = useState<any>(null);
  const [sessionId, setSessionId] = useState<string | null>(null);
  const [textInput, setTextInput] = useState("");
  const pollRef = useRef<ReturnType<typeof setInterval> | null>(null);

  const clientTools = {
    show_options: ({ results, sessionId: sid }: { results: any[]; sessionId: string }) => {
      setOptions(results || []);
      setSessionId(sid);
      setPhase("results");
      setStatusMsg("Choose an option below or say which one you want");
      return "Options displayed";
    },
    show_confirmation: ({ bookingRef, provider, eta, price }: { bookingRef: string; provider: string; eta: number; price: string }) => {
      setBooking({ bookingRef, provider, eta, price });
      setPhase("confirmed");
      setStatusMsg("Your cab is confirmed!");
      return "Confirmation displayed";
    },
  };

  const conversation = useConversation({
    clientTools,
    onConnect: () => setStatusMsg("Listening… tell me where you're going"),
    onDisconnect: () => {
      if (phase === "idle") setStatusMsg("Tap the mic or type your destination");
    },
    onMessage: ({ message, source }: { message: string; source: string }) => {
      if (source === "ai") setStatusMsg(message);
    },
    onError: () => {
      setPhase("error");
      setStatusMsg("Connection error — try text input below");
    },
  });

  const isConnected = conversation.status === "connected";
  const isConnecting = conversation.status === "connecting";

  const startVoice = useCallback(async () => {
    try {
      await navigator.mediaDevices.getUserMedia({ audio: true });
    } catch {
      setStatusMsg("Microphone blocked — use text input below");
      return;
    }
    await conversation.startSession({ agentId: AGENT_ID, connectionType: "webrtc" });
  }, [conversation]);

  const stopVoice = useCallback(() => conversation.endSession(), [conversation]);

  const startPolling = (sid: string) => {
    pollRef.current = setInterval(async () => {
      try {
        const res = await fetch(`${BACKEND_URL}/booking/status/${sid}`);
        const data = await res.json();
        if (data.status === "ready") {
          clearInterval(pollRef.current!);
          setOptions(data.results || data.options || []);
          setPhase("results");
          setStatusMsg("Results are in! Choose your cab");
        }
      } catch { }
    }, 2500);
  };

  useEffect(() => () => clearInterval(pollRef.current!), []);

  const handleText = async () => {
    const val = textInput.trim();
    if (!val) return;

    // Accept: "from X to Y, priority" OR "X to Y" OR "X to Y, fast"
    let pickup = "", dropoff = "", priority = "balanced";
    const fullMatch = val.match(/(?:from\s+)?(.+?)\s+to\s+(.+?)(?:,\s*(cheapest|fastest|cheap|fast|balanced))?$/i);
    if (fullMatch) {
      pickup = fullMatch[1].trim();
      dropoff = fullMatch[2].trim();
      priority = fullMatch[3] || "balanced";
    } else {
      setStatusMsg("Try: Airport to Downtown  or  from Airport to Downtown, cheapest");
      return;
    }

    setPhase("searching");
    setStatusMsg("Searching for cabs…");
    setTextInput("");
    try {
      const res = await fetch(`${BACKEND_URL}/booking/request`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ pickup, dropoff, priority }),
      });
      const data = await res.json();
      if (data.error) throw new Error(data.error);
      setSessionId(data.sessionId);
      const rides = data.results || data.options || [];
      if (data.status === "searching") {
        startPolling(data.sessionId);
      } else if (rides.length > 0) {
        setOptions(rides);
        setPhase("results");
        setStatusMsg("Choose your cab below");
      } else {
        setPhase("error");
        setStatusMsg("No cabs found — try a different route");
      }
    } catch (e: any) {
      setPhase("error");
      setStatusMsg(`Error: ${e.message}`);
    }
  };


  const confirmBooking = async () => {
    if (!selectedId || !sessionId) return;
    try {
      const res = await fetch(`${BACKEND_URL}/booking/confirm`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ sessionId, optionId: selectedId }),
      });
      const data = await res.json();
      if (!data.success) throw new Error(data.error);
      setBooking(data);
      setPhase("confirmed");
      setOptions([]);
    } catch (e: any) {
      setStatusMsg(`Booking failed: ${e.message}`);
    }
  };

  const reset = () => {
    setPhase("idle");
    setOptions([]);
    setBooking(null);
    setSessionId(null);
    setSelectedId(null);
    setStatusMsg("Tap the mic or type your destination");
    clearInterval(pollRef.current!);
  };

  return (
    <>
      <style>{css}</style>
      <div className="app">

        {/* Header */}
        <div className="header">
          <div className="header-pill">
            <div className="header-pill-dot" />
            AI Powered
          </div>
          <div className="header-title">Cabbie</div>
          <div className="header-sub">Your ride, instantly</div>
        </div>

        {/* Voice button */}
        <div className="voice-section">
          <div className="voice-ring">
            {isConnected && <div className="voice-ring-bg" />}
            <button
              className={`voice-btn ${isConnected ? "connected" : isConnecting ? "connecting" : "idle"}`}
              onClick={isConnected ? stopVoice : startVoice}
              aria-label={isConnected ? "Stop" : "Start voice"}
            >
              {isConnecting ? <SpinnerIcon /> : isConnected ? <StopIcon /> : <MicIcon />}
            </button>
          </div>

          {conversation.isSpeaking
            ? <div className="speaking-indicator"><span /><span /><span /><span /><span /></div>
            : <div className="voice-label">
              {isConnected ? "Tap to end call" : isConnecting ? "Connecting…" : "Tap to speak with AI"}
            </div>
          }
        </div>

        {/* Status */}
        <div className="status-bar">
          <div className={`status-dot ${phase}`} />
          <div className="status-text">{statusMsg}</div>
        </div>

        {/* Text fallback */}
        {!isConnected && phase !== "confirmed" && (
          <>
            <div className="divider" style={{ marginTop: 20 }}>
              <span>or type</span>
            </div>
            <div className="text-section">
              <input
                className="text-input"
                placeholder="from Airport to Downtown, cheapest"
                value={textInput}
                onChange={e => setTextInput(e.target.value)}
                onKeyDown={e => e.key === "Enter" && handleText()}
              />
              <button className="send-btn" onClick={handleText}>→</button>
            </div>
          </>
        )}

        {/* Options */}
        {phase === "results" && options.length > 0 && (
          <div className="options-section">
            <div className="options-label">Available rides</div>
            {options.map((opt, i) => (
              <div
                key={opt.optionId}
                className={`option-card ${selectedId === opt.optionId ? "selected" : ""}`}
                onClick={() => setSelectedId(opt.optionId)}
              >
                <div className="option-left">
                  <div className="option-rank">{i + 1}</div>
                  <div>
                    <div className="option-name">{opt.appName} · {opt.name}</div>
                    <div className="option-meta" style={{ textTransform: "capitalize" }}>{opt.category}</div>
                  </div>
                </div>
                <div className="option-right">
                  <div className="option-price">{opt.price}</div>
                  <div className="option-eta">{opt.etaMinutes} min</div>
                </div>
              </div>
            ))}
            <button className="book-btn" onClick={confirmBooking} disabled={!selectedId}>
              {selectedId ? "Confirm ride →" : "Select a ride first"}
            </button>
          </div>
        )}

        {/* Confirmation */}
        {phase === "confirmed" && booking && (
          <div className="confirmation">
            <div className="confirmation-check">✓</div>
            <div className="confirmation-ref">{booking.bookingRef}</div>
            <div className="confirmation-details">
              <strong style={{ color: "var(--text)" }}>{booking.provider}</strong> is on the way<br />
              {booking.price} · arrives in {booking.eta} min
            </div>
            <button className="new-booking-btn" onClick={reset}>Book another ride</button>
          </div>
        )}

        {/* Hint */}
        {phase === "idle" && (
          <p className="hint">
            Say <em>"I need a cab from Airport to Downtown,<br />cheapest option"</em> to get started
          </p>
        )}

      </div>
    </>
  );
}
