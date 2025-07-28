import http.server
import socketserver
import json

PORT = 8000

class JSONHandler(http.server.BaseHTTPRequestHandler):
    def do_POST(self):
        self.send_response(200)
        self.send_header("Content-type", "application/json")
        self.end_headers()
        response = {
            "session": {
                "access_token": {
                    "scope": "read_all write_programs write_vens write_events"
                }
            }
        }
        self.wfile.write(json.dumps(response).encode("utf-8"))

if __name__ == "__main__":
    with socketserver.TCPServer(("", PORT), JSONHandler) as httpd:
        print(f"Serving JSON at http://localhost:{PORT}")
        httpd.serve_forever()
