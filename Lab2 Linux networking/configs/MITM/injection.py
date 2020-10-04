from mitmproxy import http

def response(flow: http.HTTPFlow) -> None:
flow.response.content = "<h1>Injected</h1><div>Injected by MITM!</div>".encode("utf-8")