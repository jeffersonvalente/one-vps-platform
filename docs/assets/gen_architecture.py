#!/usr/bin/env python3
"""Generate docs/assets/architecture-{light,dark}.svg. Pure stdlib; run from repo root."""
from pathlib import Path

W, H = 1040, 580
FONT = "-apple-system, BlinkMacSystemFont, 'Segoe UI', 'Noto Sans', Helvetica, Arial, sans-serif"
MONO = "ui-monospace, SFMono-Regular, 'SF Mono', Menlo, Consolas, 'Liberation Mono', monospace"

THEMES = {
    "light": dict(bg="#ffffff", panel="#f6f8fa", line="#d0d7de", text="#1f2328", muted="#59636e",
                  arrow="#8c959f", blue_bg="#ddf4ff", blue="#54aeff", green_bg="#dafbe1", green="#1a7f37",
                  purple_bg="#fbefff", purple="#8250df", amber_bg="#fff8c5", amber="#d4a72c",
                  red_bg="#ffebe9", red="#cf222e"),
    "dark": dict(bg="#0d1117", panel="#161b22", line="#30363d", text="#e6edf3", muted="#8b949e",
                 arrow="#6e7681", blue_bg="#0c2d6b", blue="#388bfd", green_bg="#0f3a1e", green="#3fb950",
                 purple_bg="#2d1b4e", purple="#a371f7", amber_bg="#3a2d00", amber="#d29922",
                 red_bg="#4a1212", red="#f85149"),
}


def build(t):
    o = []
    a = o.append
    a(f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}" role="img" '
      f'aria-label="How one-vps-platform works">')
    a(f'<rect width="{W}" height="{H}" fill="{t["bg"]}"/>')
    a('<defs><marker id="head" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" '
      f'orient="auto-start-reverse"><path d="M0,0 L10,5 L0,10 z" fill="{t["arrow"]}"/></marker></defs>')

    def box(x, y, w, h, fill, stroke, rx=8, sw=1, dash=None):
        d = f' stroke-dasharray="{dash}"' if dash else ""
        a(f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{rx}" fill="{fill}" stroke="{stroke}" stroke-width="{sw}"{d}/>')

    def txt(x, y, s, size=13, fill=None, weight=400, anchor="start", mono=False):
        s = s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
        f = MONO if mono else FONT
        a(f'<text x="{x}" y="{y}" font-family="{f}" font-size="{size}" font-weight="{weight}" '
          f'fill="{fill or t["text"]}" text-anchor="{anchor}">{s}</text>')

    def pill(x, y, s, bg, st, w=None):
        w = w or int(len(s) * 7.4 + 18)
        box(x, y, w, 24, bg, st, rx=6)
        txt(x + w / 2, y + 16.5, s, 12.5, weight=500, anchor="middle", mono=True)
        return w

    def arrow(x1, y1, x2, y2, color=None, dash=None):
        d = f' stroke-dasharray="{dash}"' if dash else ""
        a(f'<line x1="{x1}" y1="{y1}" x2="{x2}" y2="{y2}" stroke="{color or t["arrow"]}" stroke-width="1.5" marker-end="url(#head)"{d}/>')

    # ---------- left: clients ----------
    box(16, 60, 150, 120, t["panel"], t["line"])
    txt(91, 84, "You", 13, t["muted"], 600, "middle")
    txt(91, 110, "laptop", 13, anchor="middle")
    txt(91, 132, "phone", 13, anchor="middle")
    txt(91, 154, "VS Code Remote-SSH", 12, t["muted"], anchor="middle")

    # tailscale pipe
    box(186, 100, 150, 40, t["green_bg"], t["green"], rx=20)
    txt(261, 125, "Tailscale mesh", 13, t["green"], 600, "middle")
    arrow(166, 120, 186, 120)
    arrow(336, 120, 364, 120)

    # internet blocked
    box(16, 216, 150, 70, t["red_bg"], t["red"], dash="4 3")
    txt(91, 240, "Internet", 13, t["red"], 600, "middle")
    txt(91, 262, "0 open TCP ports", 12, anchor="middle")
    txt(91, 278, "firewall: default deny", 11, t["muted"], anchor="middle")
    a(f'<line x1="166" y1="251" x2="364" y2="251" stroke="{t["red"]}" stroke-width="1.5" stroke-dasharray="4 3"/>')
    a(f'<line x1="350" y1="241" x2="362" y2="261" stroke="{t["red"]}" stroke-width="2"/>')
    a(f'<line x1="362" y1="241" x2="350" y2="261" stroke="{t["red"]}" stroke-width="2"/>')

    # ---------- VPS frame ----------
    box(364, 24, 660, 540, t["bg"], t["line"], rx=10, sw=1.5)
    txt(384, 48, "VPS", 14, weight=700)
    txt(416, 48, "4 vCPU · 16 GB · Ubuntu LTS", 12.5, t["muted"])
    pill(880, 32, "sshd on tailscale0", t["green_bg"], t["green"], 130)

    # tenants row
    box(384, 70, 620, 118, t["panel"], t["line"])
    txt(400, 92, "Tenants", 13, t["muted"], 600)
    txt(455, 92, "one Linux user each · home 0700 · no sudo · own git identity", 12, t["muted"])
    xs = 400
    for name, extra in (("client-a", "rootless Docker"), ("client-b", ""), ("personal", "kubeconfig"), ("ops", "sudo only")):
        box(xs, 104, 140, 70, t["bg"], t["line"], rx=6)
        txt(xs + 70, 126, name, 13, weight=600, anchor="middle", mono=True)
        txt(xs + 70, 146, "Claude Code · tmux", 11, t["muted"], anchor="middle")
        if extra:
            txt(xs + 70, 163, extra, 11, t["purple"] if "Docker" in extra else t["muted"], anchor="middle")
        xs += 150

    # k3s row
    box(384, 206, 620, 196, t["panel"], t["line"])
    txt(400, 228, "k3s", 13, t["muted"], 600)
    txt(428, 228, "single node · traefik/servicelb off · local-path", 12, t["muted"])

    box(400, 244, 290, 64, t["bg"], t["line"], rx=6)
    txt(410, 264, "Ingress & TLS", 12.5, weight=600)
    pill(410, 274, "ingress-nginx", t["blue_bg"], t["blue"], 108)
    pill(526, 274, "cert-manager", t["blue_bg"], t["blue"], 104)
    txt(640, 290, "DNS-01", 11, t["muted"], mono=True)

    box(704, 244, 284, 64, t["bg"], t["line"], rx=6)
    txt(714, 264, "GitOps", 12.5, weight=600)
    pill(714, 274, "ArgoCD core", t["purple_bg"], t["purple"], 100)
    txt(822, 290, "syncs k8s/apps/ from this repo", 11, t["muted"])

    box(400, 320, 588, 70, t["bg"], t["line"], rx=6)
    txt(410, 340, "Observability", 12.5, weight=600)
    pill(410, 352, "SigNoz", t["amber_bg"], t["amber"], 66)
    pill(484, 352, "ClickHouse", t["amber_bg"], t["amber"], 92)
    pill(584, 352, "otel-collector", t["amber_bg"], t["amber"], 110)
    txt(708, 362, "shared; tenants split by", 11, t["muted"])
    txt(708, 376, "service.name / deployment.environment", 11, t["muted"], mono=True)
    txt(708, 341, "service accounts per tenant: viewer (runtime), editor (automation)", 11, t["muted"])

    # bottom row: how it is managed
    box(384, 420, 300, 128, t["panel"], t["line"])
    txt(400, 442, "Provisioned by", 13, t["muted"], 600)
    pill(400, 454, "Terraform", t["purple_bg"], t["purple"], 96)
    txt(504, 470, "VPS import · DNS · ACL · bucket", 11, t["muted"])
    pill(400, 486, "Ansible", t["purple_bg"], t["purple"], 96)
    txt(504, 502, "host · users · k3s · docker", 11, t["muted"])
    pill(400, 518, "SOPS + age", t["purple_bg"], t["purple"], 96)
    txt(504, 534, "secrets never in plain text", 11, t["muted"])

    box(704, 420, 300, 128, t["panel"], t["line"])
    txt(720, 442, "Leaves the box", 13, t["muted"], 600)
    pill(720, 454, "restic", t["blue_bg"], t["blue"], 108)
    txt(836, 470, "nightly to object storage", 11, t["muted"])
    pill(720, 486, "Let's Encrypt", t["blue_bg"], t["blue"], 108)
    txt(836, 502, "DNS-01 via Cloudflare API", 11, t["muted"])
    txt(720, 536, "Nothing else. No inbound traffic from the internet.", 11, t["muted"])

    a("</svg>")
    return "\n".join(o)


if __name__ == "__main__":
    out = Path(__file__).parent
    for name, theme in THEMES.items():
        (out / f"architecture-{name}.svg").write_text(build(theme), encoding="utf-8")
        print(f"wrote {out / f'architecture-{name}.svg'}")
