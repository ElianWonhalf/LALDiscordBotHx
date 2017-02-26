package laldiscordbothx.utils;

import nodejs.http.HTTPClientRequest;
import nodejs.http.ServerResponse;
import nodejs.http.HTTPS;
import nodejs.http.HTTP;

class HttpUtils {
    public static function query(secured: Bool, host: String, path: String, method: HTTPMethod, callback: String->Void, ?data: String, ?additionnalHeaders: Map<String, String>): Void {
        var port = 80;
        var contentLength = 0;

        if (data != null) {
            contentLength = data.length;
        }

        if (secured) {
            port = 443;
        }

        var options = {
            host: host,
            port: port,
            path: path,
            method: method,
            headers: {
                'User-Agent': 'laldiscordbothx/2.0 (by ElianWonhalf)',
                'Content-Type': 'application/json',
                'Content-Length': contentLength
            }
        };

        if (additionnalHeaders != null) {
            for (header in additionnalHeaders.keys()) {
                Reflect.setField(options.headers, header, additionnalHeaders.get(header));
            }
        }

        var req: HTTPClientRequest;

        if (secured) {
            req = HTTPS.request(cast options, function (res: ServerResponse) {
                var output = '';

                res.on('data', function (chunck) {
                    output += chunck;
                });

                res.on('end', function() {
                    callback(output);
                });
            });
        } else {
            req = HTTP.request(cast options, function (res: ServerResponse) {
                var output = '';

                res.on('data', function (chunck) {
                    output += chunck;
                });

                res.on('end', function() {
                    callback(output);
                });
            });
        }

        if (data != null) {
            req.write(data);
        }

        req.end();
    }
}
