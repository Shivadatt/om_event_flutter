import http.server
import socketserver
import os
import sys

PORT = 8765
DIRECTORY = os.path.abspath("build/web")

class SPAHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)

    def end_headers(self):
        self.send_header('Cache-Control', 'no-store, no-cache, must-revalidate, max-age=0')
        self.send_header('Pragma', 'no-cache')
        self.send_header('Expires', '0')
        super().end_headers()

    def do_GET(self):
        # Translate path to local filesystem path
        path = self.translate_path(self.path)
        # If path does not exist and doesn't look like a static asset with an extension
        if not os.path.exists(path) and "." not in os.path.basename(self.path):
            self.path = "/index.html"
        return super().do_GET()

if __name__ == "__main__":
    os.chdir(DIRECTORY)
    with socketserver.TCPServer(("", PORT), SPAHandler) as httpd:
        print(f"SPA Server running at http://localhost:{PORT}")
        sys.stdout.flush()
        httpd.serve_forever()
