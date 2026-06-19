#!/usr/bin/env bash
# mic-tune.sh — interactive microphone + RNNoise level tuner for hyprsimple.
#
# Tunes the four parameters that govern microphone level/quality:
#   1. Hardware ADC capture gain   (ALSA "Capture")        — clipping vs. headroom
#   2. Hardware mic boost          (ALSA "*Mic Boost")     — extra analog gain
#   3. Raw input software volume   (PipeWire, hardware mic)
#   4. RNNoise source software vol (PipeWire, "Noise Suppressed Source")
#
# Plus a record-and-measure test that captures a few seconds, reports the
# peak/RMS level, and tells you whether you are clipping or too quiet — the
# reliable way to calibrate. All devices are auto-detected (no hardcoding), so
# it is portable across machines.
#
# Software volumes persist via WirePlumber automatically. The hardware ALSA
# gains need `sudo alsactl store` to survive reboot — option [S] does that.

set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; YELLOW=$'\033[1;33m'; BLUE=$'\033[0;34m'; NC=$'\033[0m'
RNNOISE_SRC=""; HW_SRC=""; CARD=""; CAP_CTL=""; BOOST_CTL=""

die() { echo -e "${RED}Error:${NC} $*" >&2; exit 1; }

check_deps() {
  for c in pactl wpctl amixer pw-record python3; do
    command -v "$c" >/dev/null 2>&1 || die "missing dependency: $c"
  done
}

detect() {
  # RNNoise virtual source (created by 99-input-denoising.conf)
  if pactl list sources short 2>/dev/null | grep -q '\brnnoise_source\b'; then
    RNNOISE_SRC="rnnoise_source"
  fi
  # Hardware mic = first real ALSA input source
  HW_SRC="$(pactl list sources short 2>/dev/null | awk '/alsa_input/{print $2; exit}')"
  [[ -n $HW_SRC ]] || die "no hardware microphone (alsa_input) found"
  # ALSA card index for that source
  CARD="$(pactl list sources 2>/dev/null \
        | awk -v s="$HW_SRC" '$0 ~ "Name: "s{f=1} f&&/alsa.card =/{gsub(/[^0-9]/,"");print;exit}')"
  CARD="${CARD:-0}"
  # Capture gain control (near-universal name)
  amixer -c "$CARD" sget "Capture" &>/dev/null && CAP_CTL="Capture"
  # Mic boost control name varies by codec
  for b in "Internal Mic Boost" "Mic Boost" "Front Mic Boost" "Boost"; do
    if amixer -c "$CARD" sget "$b" &>/dev/null; then BOOST_CTL="$b"; break; fi
  done
}

ctl_line() {  # $1=control -> "value [pct] [dB]" of first channel, or "n/a"
  amixer -c "$CARD" sget "$1" 2>/dev/null \
    | grep -m1 -oE '[0-9]+ \[[0-9]+%\]( \[-?[0-9.]+dB\])?' || echo "n/a"
}
src_vol() { pactl get-source-volume "$1" 2>/dev/null | grep -oE '[0-9]+%' | head -1; }

status() {
  echo -e "${BLUE}=== Microphone tuning status ===${NC}"
  echo -e "ALSA card        : ${GREEN}$CARD${NC}"
  echo -e "Hardware mic     : ${GREEN}$HW_SRC${NC}"
  echo -e "RNNoise source   : ${GREEN}${RNNOISE_SRC:-<not loaded>}${NC}"
  echo
  echo -e "1) Hardware Capture gain : ${YELLOW}$([[ -n $CAP_CTL ]] && ctl_line "$CAP_CTL" || echo 'n/a')${NC}"
  echo -e "2) Mic Boost ($BOOST_CTL) : ${YELLOW}$([[ -n $BOOST_CTL ]] && ctl_line "$BOOST_CTL" || echo 'n/a')${NC}"
  echo -e "3) Raw mic software vol  : ${YELLOW}$(src_vol "$HW_SRC")${NC}"
  echo -e "4) RNNoise software vol  : ${YELLOW}$([[ -n $RNNOISE_SRC ]] && src_vol "$RNNOISE_SRC" || echo 'n/a')${NC}"
  echo
}

analyze() {  # $1 = wav file -> prints rms/peak + verdict
  python3 - "$1" <<'PY'
import struct, math, sys
b = open(sys.argv[1], "rb").read(); i = 12; data = None; bps = 16
while i < len(b):
    cid = b[i:i+4]; sz = struct.unpack('<I', b[i+4:i+8])[0]
    if cid == b'fmt ':  bps = struct.unpack('<H', b[i+22:i+24])[0]
    if cid == b'data':  data = b[i+8:i+8+sz]
    i += 8 + sz + (sz & 1)
if not data: print("  (no audio captured)"); sys.exit()
c = len(data)//2; v = struct.unpack('<%dh' % c, data[:c*2]); fs = 32767
rms = math.sqrt(sum(x*x for x in v)/len(v))/fs
peak = max(abs(x) for x in v)/fs*100
verdict = ("CLIPPING — lower the gain"        if peak >= 99 else
           "hot, watch for clipping"          if peak >= 90 else
           "good level"                       if peak >= 35 else
           "a bit low"                         if peak >= 12 else
           "too quiet — raise the gain")
print("  rms=%.4f  peak=%.1f%% FS  ->  %s" % (rms, peak, verdict))
PY
}

record_test() {
  local target="${RNNOISE_SRC:-$HW_SRC}" secs=5 tmp
  tmp="$(mktemp --suffix=.wav)"
  echo -e "${YELLOW}Recording ${secs}s from '${target}'. Speak normally now...${NC}"
  timeout "$((secs+1))" pw-record --target "$target" "$tmp" 2>/dev/null
  echo -e "${BLUE}Result (final denoised output):${NC}"
  analyze "$tmp"
  rm -f "$tmp"
}

set_ctl_pct() {  # $1=control  $2=percent
  [[ -n $1 ]] || { echo -e "${RED}control not available${NC}"; return; }
  amixer -c "$CARD" sset "$1" "${2}%" >/dev/null 2>&1 \
    && echo -e "${GREEN}$1 -> $(ctl_line "$1")${NC}" \
    || echo -e "${RED}failed to set $1${NC}"
}
set_src_pct() { pactl set-source-volume "$1" "${2}%" && echo -e "${GREEN}$1 -> ${2}%${NC}"; }

persist() {
  echo -e "${YELLOW}Persisting ALSA hardware gains (needs root)...${NC}"
  if sudo alsactl store; then
    echo -e "${GREEN}Saved — hardware gains survive reboot.${NC}"
  else
    echo -e "${RED}alsactl store failed (run 'sudo alsactl store' manually).${NC}"
  fi
}

menu() {
  while true; do
    echo
    status
    cat <<EOF
  [t] Record test (speak — measures level)
  [1] Set hardware Capture gain (%)
  [2] Toggle / set Mic Boost (%)
  [3] Set raw mic software volume (%)
  [4] Set RNNoise software volume (%)
  [s] Save hardware gains (sudo alsactl store)
  [q] Quit
EOF
    read -rp "> " choice
    case "$choice" in
      t|T) record_test ;;
      1) read -rp "Capture gain % (0-100): " p; set_ctl_pct "$CAP_CTL" "$p" ;;
      2) read -rp "Mic boost % (0=off): " p;   set_ctl_pct "$BOOST_CTL" "$p" ;;
      3) read -rp "Raw mic volume %: " p;       set_src_pct "$HW_SRC" "$p" ;;
      4) [[ -n $RNNOISE_SRC ]] && { read -rp "RNNoise volume %: " p; set_src_pct "$RNNOISE_SRC" "$p"; } \
                                || echo -e "${RED}RNNoise source not loaded${NC}" ;;
      s|S) persist ;;
      q|Q) exit 0 ;;
      *) echo -e "${RED}unknown option${NC}" ;;
    esac
  done
}

check_deps
detect
menu
