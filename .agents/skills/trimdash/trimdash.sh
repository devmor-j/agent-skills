#!/usr/bin/env bash
# trimdash.sh — compact markdown table padding (idempotent, fence-aware, CRLF-safe).
# Skips files under TRIMDASH_SKIP="prefix1:prefix2" path prefixes (env, optional).
# Rewrites only files whose bytes change; preserves file mode.
# Exit: 0 ok, 1 usage error, 2 skipped/failed.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: trimdash.sh [options] <file>...
  -n, --dry-run    Report changes without writing.
  -q, --quiet      Suppress per-file lines.
  -h, --help       Show this help.
Env:
  TRIMDASH_SKIP  colon-separated path prefixes to skip.
EOF
  exit "${1:-0}"
}

dry_run=0 quiet=0 files=()
while [ $# -gt 0 ]; do
  case "$1" in
  -n | --dry-run) dry_run=1 ;;
  -q | --quiet) quiet=1 ;;
  -h | --help) usage 0 ;;
  --)
    shift
    while [ $# -gt 0 ]; do
      files+=("$1")
      shift
    done
    break
    ;;
  -*)
    echo "trimdash: unknown option: $1" >&2
    usage 1
    ;;
  *) files+=("$1") ;;
  esac
  shift
done
[ ${#files[@]} -gt 0 ] || {
  echo "trimdash: no input files" >&2
  usage 1
}

is_skipped() {
  local f="$1" p rest="${TRIMDASH_SKIP:-}"
  while [ -n "$rest" ]; do
    p=${rest%%:*}
    [ -n "$p" ] && { case "$f" in "$p"|"$p"/*) return 0 ;; esac; }
    [ "$rest" = "$p" ] && break
    rest=${rest#*:}
  done
  return 1
}

tmp=""
trap '[ -n "$tmp" ] && rm -f "$tmp"' EXIT INT TERM

AWK_PROG='
function prot(s,   out,i,n,c,k){
  out=""; n=length(s)
  for(i=1;i<=n;i++){
    c=substr(s,i,1)
    if(c=="\\"){
      k=0; while(substr(s,i+k,1)=="\\") k++
      if(substr(s,i+k,1)=="|"){
        if(k%2){ out=out substr(s,i,k-1) "\001"; i+=k }
        else   { out=out substr(s,i,k);         i+=k-1 }
      } else   { out=out substr(s,i,k);         i+=k-1 }
    } else out=out c
  }
  return out
}
BEGIN{ infence=0; fchar=""; flen=0; f_ind=0; rownum=0 }
{
  line=$0; cr=""
  if(substr(line,length(line),1)=="\r"){ cr="\r"; line=substr(line,1,length(line)-1) }
  t=line; sub(/^[ \t]+/,"",t)
  ind=substr(line,1,length(line)-length(t))
  if(t ~ /^(`{3,}|~{3,})/){
    c=substr(t,1,1); m=0; while(substr(t,1+m,1)==c) m++
    if(!infence){ infence=1; fchar=c; flen=m; f_ind=length(ind) }
    else if(c==fchar && m>=flen && length(ind)<=f_ind+3 && substr(t,m+1) ~ /^[ \t]*$/) infence=0
    rownum=0; print line cr; next
  }
  if(infence){ print line cr; next }
  if(t ~ /^\|/){
    rownum++
    if(rownum==2 && t ~ /^\|[ \t]*:?-+:?[ \t]*(\|[ \t]*:?-+:?[ \t]*)*\|?[ \t]*$/){
      l=t; gsub(/[ \t]/,"",l); gsub(/-+/,"-",l); print ind l cr; next
    }
    l=prot(t); gsub(/\|[ \t]+/,"|",l); gsub(/[ \t]+\|/,"|",l); gsub(/\001/,"\\|",l)
    print ind l cr; next
  }
  rownum=0; print line cr
}
'

rc=0 changed=0
for f in "${files[@]}"; do
  if [ ! -f "$f" ]; then
    echo "trimdash: skip (missing): $f" >&2
    rc=2
    continue
  fi
  if is_skipped "$f"; then
    echo "trimdash: skip (TRIMDASH_SKIP prefix): $f" >&2
    rc=2
    continue
  fi

  tmp=$(mktemp "${TMPDIR:-/tmp}/trimdash.XXXXXX") || {
    echo "trimdash: mktemp failed" >&2
    rc=2
    continue
  }
  awk "$AWK_PROG" "$f" >"$tmp" || {
    echo "trimdash: awk failed: $f" >&2
    rm -f "$tmp"
    tmp=""
    rc=2
    continue
  }

  # awk always appends a newline; restore a missing one.
  if [ -s "$f" ] && [ -n "$(tail -c 1 "$f" 2>/dev/null)" ]; then
    sz=$(wc -c <"$tmp")
    if [ "$sz" -gt 0 ]; then head -c $((sz - 1)) "$tmp" >"$tmp.s" && mv "$tmp.s" "$tmp"; fi
  fi

  if cmp -s "$f" "$tmp"; then
    rm -f "$tmp"
    tmp=""
    if [ "$quiet" -eq 0 ]; then echo "clean: $f"; fi
    continue
  fi
  before=$(wc -c <"$f")
  after=$(wc -c <"$tmp")
  if [ "$dry_run" -eq 1 ]; then
    echo "would compact: $f ($before -> $after bytes, -$((before - after)))"
    rm -f "$tmp"
    tmp=""
    changed=$((changed + 1))
    continue
  fi
  m=$(stat -c '%a' "$f" 2>/dev/null || stat -f '%Lp' "$f" 2>/dev/null || true)
  if [ -n "$m" ]; then chmod "$m" "$tmp" 2>/dev/null || true; fi
  if ! mv "$tmp" "$f"; then
    echo "trimdash: mv failed: $f" >&2
    rm -f "$tmp"
    tmp=""
    rc=2
    continue
  fi
  tmp=""
  if [ "$quiet" -eq 0 ]; then echo "compact: $f ($before -> $after bytes, -$((before - after)))"; fi
  changed=$((changed + 1))
done

if [ "$dry_run" -eq 1 ]; then echo "files that would change: $changed"; else echo "files changed: $changed"; fi
exit $rc
