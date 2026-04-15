from fastapi import FastAPI
from fastapi.responses import HTMLResponse

app = FastAPI(title="Mission Status API", version="1.0.0")

APP_NAME = "Mission Status API"
APP_ENV = "prod"  # optional default; can be overridden below if you later wire env vars
APP_VERSION = "1.0.0"


@app.get("/", response_class=HTMLResponse)
def root() -> str:
    return f"""
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <title>{APP_NAME}</title>
        <style>
            :root {{
                --bg: #0b1020;
                --panel: rgba(255,255,255,0.08);
                --panel-border: rgba(255,255,255,0.15);
                --text: #f5f7fb;
                --muted: #b8c0d4;
                --accent: #6ea8fe;
                --accent-2: #7ef0c6;
                --success: #22c55e;
                --shadow: 0 10px 30px rgba(0,0,0,0.35);
            }}

            * {{
                box-sizing: border-box;
            }}

            body {{
                margin: 0;
                min-height: 100vh;
                font-family: Inter, Arial, sans-serif;
                color: var(--text);
                background:
                    radial-gradient(circle at top left, rgba(110,168,254,0.25), transparent 30%),
                    radial-gradient(circle at bottom right, rgba(126,240,198,0.16), transparent 28%),
                    linear-gradient(135deg, #0b1020 0%, #11182d 45%, #0d1326 100%);
                display: flex;
                align-items: center;
                justify-content: center;
                padding: 32px;
            }}

            .card {{
                width: 100%;
                max-width: 980px;
                background: var(--panel);
                border: 1px solid var(--panel-border);
                border-radius: 24px;
                box-shadow: var(--shadow);
                backdrop-filter: blur(12px);
                overflow: hidden;
            }}

            .hero {{
                padding: 40px 40px 24px;
                border-bottom: 1px solid rgba(255,255,255,0.1);
            }}

            .badge {{
                display: inline-flex;
                align-items: center;
                gap: 8px;
                padding: 8px 14px;
                border-radius: 999px;
                background: rgba(34,197,94,0.12);
                color: #c9f7d7;
                font-size: 14px;
                font-weight: 600;
                margin-bottom: 18px;
                border: 1px solid rgba(34,197,94,0.24);
            }}

            .dot {{
                width: 10px;
                height: 10px;
                border-radius: 999px;
                background: var(--success);
                box-shadow: 0 0 10px rgba(34,197,94,0.75);
            }}

            h1 {{
                margin: 0 0 12px;
                font-size: 40px;
                line-height: 1.1;
                letter-spacing: -0.02em;
            }}

            .subtitle {{
                margin: 0;
                color: var(--muted);
                font-size: 18px;
                line-height: 1.6;
                max-width: 760px;
            }}

            .content {{
                display: grid;
                grid-template-columns: 1.1fr 0.9fr;
                gap: 24px;
                padding: 28px 40px 40px;
            }}

            .panel {{
                background: rgba(255,255,255,0.04);
                border: 1px solid rgba(255,255,255,0.08);
                border-radius: 20px;
                padding: 24px;
            }}

            .panel h2 {{
                margin: 0 0 18px;
                font-size: 20px;
            }}

            .meta-grid {{
                display: grid;
                grid-template-columns: repeat(2, minmax(0, 1fr));
                gap: 14px;
            }}

            .meta-item {{
                padding: 16px;
                border-radius: 16px;
                background: rgba(255,255,255,0.04);
                border: 1px solid rgba(255,255,255,0.08);
            }}

            .meta-label {{
                font-size: 12px;
                color: var(--muted);
                text-transform: uppercase;
                letter-spacing: 0.08em;
                margin-bottom: 8px;
            }}

            .meta-value {{
                font-size: 18px;
                font-weight: 700;
            }}

            .links {{
                display: grid;
                gap: 12px;
            }}

            .link-card {{
                display: flex;
                justify-content: space-between;
                align-items: center;
                text-decoration: none;
                color: var(--text);
                padding: 16px 18px;
                border-radius: 16px;
                background: rgba(255,255,255,0.04);
                border: 1px solid rgba(255,255,255,0.08);
                transition: transform 0.18s ease, border-color 0.18s ease, background 0.18s ease;
            }}

            .link-card:hover {{
                transform: translateY(-2px);
                border-color: rgba(110,168,254,0.5);
                background: rgba(110,168,254,0.08);
            }}

            .link-title {{
                font-weight: 700;
                margin-bottom: 4px;
            }}

            .link-desc {{
                font-size: 14px;
                color: var(--muted);
            }}

            .arrow {{
                font-size: 22px;
                color: var(--accent);
            }}

            .footer {{
                padding: 0 40px 30px;
                color: var(--muted);
                font-size: 14px;
            }}

            @media (max-width: 820px) {{
                .content {{
                    grid-template-columns: 1fr;
                    padding: 24px;
                }}

                .hero {{
                    padding: 28px 24px 20px;
                }}

                .footer {{
                    padding: 0 24px 24px;
                }}

                h1 {{
                    font-size: 32px;
                }}

                .meta-grid {{
                    grid-template-columns: 1fr;
                }}
            }}
        </style>
    </head>
    <body>
        <div class="card">
            <section class="hero">
                <div class="badge">
                    <span class="dot"></span>
                    Service Running
                </div>
                <h1>{APP_NAME}</h1>
                <p class="subtitle">
                    A cloud-native FastAPI service deployed through automated CI/CD to Kubernetes.
                    This landing page provides a clean operational view while preserving all existing API endpoints.
                </p>
            </section>

            <section class="content">
                <div class="panel">
                    <h2>Service Overview</h2>
                    <div class="meta-grid">
                        <div class="meta-item">
                            <div class="meta-label">Application</div>
                            <div class="meta-value">{APP_NAME}</div>
                        </div>
                        <div class="meta-item">
                            <div class="meta-label">Environment</div>
                            <div class="meta-value">{APP_ENV}</div>
                        </div>
                        <div class="meta-item">
                            <div class="meta-label">Version</div>
                            <div class="meta-value">{APP_VERSION}</div>
                        </div>
                        <div class="meta-item">
                            <div class="meta-label">Status</div>
                            <div class="meta-value">Running</div>
                        </div>
                    </div>
                </div>

                <div class="panel">
                    <h2>API Endpoints</h2>
                    <div class="links">
                        <a class="link-card" href="/health">
                            <div>
                                <div class="link-title">/health</div>
                                <div class="link-desc">Liveness and readiness endpoint</div>
                            </div>
                            <div class="arrow">→</div>
                        </a>

                        <a class="link-card" href="/status">
                            <div>
                                <div class="link-title">/status</div>
                                <div class="link-desc">Current application service state</div>
                            </div>
                            <div class="arrow">→</div>
                        </a>

                        <a class="link-card" href="/version">
                            <div>
                                <div class="link-title">/version</div>
                                <div class="link-desc">Application version metadata</div>
                            </div>
                            <div class="arrow">→</div>
                        </a>
                    </div>
                </div>
            </section>

            <div class="footer">
                Built for a production-style DevSecOps and multi-cloud deployment demonstration.
            </div>
        </div>
    </body>
    </html>
    """


@app.get("/health")
def health() -> dict:
    return {"status": "ok"}


@app.get("/status")
def status() -> dict:
    return {
        "service": "mission-status-api",
        "environment": APP_ENV,
        "status": "running",
    }


@app.get("/version")
def version() -> dict:
    return {"version": APP_VERSION}
