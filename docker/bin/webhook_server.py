#!/usr/bin/env python3
import http.server
import subprocess
import sys

PORT = 9000


class Handler(http.server.BaseHTTPRequestHandler):
    def handle_process(self):
        if self.path.rstrip("/") != "/hooks/process":
            self.send_error(404)
            return

        self.send_response(200)
        self.send_header("Content-Type", "text/plain; charset=utf-8")
        self.send_header("Transfer-Encoding", "chunked")
        self.end_headers()

        proc = subprocess.Popen(
            ["process.sh"],
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            bufsize=1,
            text=True,
        )
        try:
            for line in proc.stdout:
                self._write_chunk(line.encode())
        except BrokenPipeError:
            pass
        finally:
            proc.wait()
            self._write_chunk(f"\n=== exit={proc.returncode} ===\n".encode())
            try:
                self.wfile.write(b"0\r\n\r\n")
            except BrokenPipeError:
                pass

    def _write_chunk(self, data: bytes):
        try:
            self.wfile.write(b"%x\r\n%b\r\n" % (len(data), data))
            self.wfile.flush()
        except BrokenPipeError:
            pass

    do_GET = handle_process
    do_POST = handle_process

    def log_message(self, fmt, *args):
        sys.stderr.write("%s - %s\n" % (self.address_string(), fmt % args))


if __name__ == "__main__":
    print(f"listening on :{PORT}, GET/POST /hooks/process to trigger a sync run")
    http.server.HTTPServer(("0.0.0.0", PORT), Handler).serve_forever()
