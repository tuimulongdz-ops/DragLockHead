import Foundation
import JavaScriptCore

struct JSOutput {
    var particles: [JSParticle] = []
    var path: [JSPoint] = []
    var color: String = ""
    var text: String = ""
    var number: Double = 0
    var log: [String] = []
}

struct JSParticle {
    var x: Double
    var y: Double
    var r: Double
    var a: Double
}

struct JSPoint {
    var x: Double
    var y: Double
}

final class JSEngine {

    static let shared = JSEngine()
    private var ctx: JSContext?
    private(set) var lastOutput: JSOutput?
    private var logBuffer: [String] = []

    private init() {
        setup()
    }

    private func setup() {
        guard let c = JSContext() else { return }

        c.exceptionHandler = { [weak self] _, e in
            let m = e?.toString() ?? "JS Error"
            self?.logBuffer.append("[ERR] \(m)")
        }

        let logFn: @convention(block) (String) -> Void = {
            [weak self] s in
            self?.logBuffer.append(s)
            if (self?.logBuffer.count ?? 0) > 300 {
                self?.logBuffer.removeFirst()
            }
        }

        let outputFn: @convention(block) (JSValue) -> Void = {
            [weak self] v in
            self?.parseOutput(v)
        }

        c.setObject(
            unsafeBitCast(logFn, to: AnyObject.self),
            forKeyedSubscript: "native_log" as NSString
        )
        c.setObject(
            unsafeBitCast(outputFn, to: AnyObject.self),
            forKeyedSubscript: "native_output" as NSString
        )

        c.evaluateScript("""
        var console = {
            log: function() {
                var m = Array.prototype
                    .slice.call(arguments)
                    .join(' ');
                native_log(String(m));
            },
            error: function() {
                var m = Array.prototype
                    .slice.call(arguments)
                    .join(' ');
                native_log('[ERR] ' + m);
            }
        };
        window.OUTPUT = {
            particles: [],
            path: [],
            color: '',
            text: '',
            number: 0
        };
        function emit() {
            native_output(window.OUTPUT);
        }
        function addParticle(x, y, r, a) {
            window.OUTPUT.particles.push({
                x: x, y: y, r: r, a: a
            });
        }
        function addPathPoint(x, y) {
            window.OUTPUT.path.push({ x: x, y: y });
        }
        function setColor(c) { window.OUTPUT.color = c; }
        function setText(t) { window.OUTPUT.text = t; }
        function setNumber(n) { window.OUTPUT.number = n; }
        """)

        ctx = c
    }

    private func parseOutput(_ v: JSValue) {
        guard let dict = v.toDictionary()
            as? [String: Any] else {
            return
        }

        var out = JSOutput()

        if let arr = dict["particles"]
            as? [[String: Any]] {
            for p in arr {
                let x = (p["x"] as? NSNumber)?
                    .doubleValue ?? 0
                let y = (p["y"] as? NSNumber)?
                    .doubleValue ?? 0
                let r = (p["r"] as? NSNumber)?
                    .doubleValue ?? 2
                let a = (p["a"] as? NSNumber)?
                    .doubleValue ?? 1
                out.particles.append(JSParticle(
                    x: x, y: y, r: r, a: a
                ))
            }
        }

        if let arr = dict["path"]
            as? [[String: Any]] {
            for p in arr {
                let x = (p["x"] as? NSNumber)?
                    .doubleValue ?? 0
                let y = (p["y"] as? NSNumber)?
                    .doubleValue ?? 0
                out.path.append(JSPoint(x: x, y: y))
            }
        }

        out.color = (dict["color"] as? String) ?? ""
        out.text = (dict["text"] as? String) ?? ""
        out.number = (dict["number"] as? NSNumber)?
            .doubleValue ?? 0
        out.log = logBuffer

        lastOutput = out
    }

    func run(_ code: String) -> JSOutput {
        logBuffer.removeAll()
        lastOutput = nil

        guard let c = ctx else {
            var o = JSOutput()
            o.log = ["JSContext init failed"]
            return o
        }

        c.evaluateScript("""
        window.OUTPUT = {
            particles: [],
            path: [],
            color: '',
            text: '',
            number: 0
        };
        """)

        _ = c.evaluateScript(code)

        if c.exception != nil {
            let e = c.exception?.toString()
                ?? "Unknown"
            c.exception = nil
            logBuffer.append("[ERR] \(e)")
        }

        if lastOutput == nil {
            if let v = c.objectForKeyedSubscript(
                "OUTPUT"
            ) {
                parseOutput(v)
            }
        }

        var result = lastOutput ?? JSOutput()
        result.log = logBuffer
        lastOutput = result
        return result
    }
}
