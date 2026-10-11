import Foundation

struct JSScript: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let desc: String
    let code: String
}

struct JSScripts {

    static let all: [JSScript] = [

        JSScript(
            name: "PARTICLE STORM",
            icon: "🌪️",
            desc: "Bão hạt JS → Canvas",
            code: """
var count = 60;
for (var i = 0; i < count; i++) {
  var a = (i / count) * Math.PI * 2;
  var r = 30 + Math.random() * 80;
  addParticle(
    50 + Math.cos(a) * r,
    50 + Math.sin(a) * r,
    2 + Math.random() * 4,
    0.4 + Math.random() * 0.6
  );
}
setColor("#00d4ff");
setText("Particle Storm: " + count);
console.log("Generated " + count);
emit();
"""
        ),

        JSScript(
            name: "AIM SPIRAL",
            icon: "🌀",
            desc: "Đường xoắn ốc",
            code: """
var points = 100;
for (var i = 0; i < points; i++) {
  var t = i / points * Math.PI * 6;
  var r = i / points * 45;
  addPathPoint(
    50 + Math.cos(t) * r,
    50 + Math.sin(t) * r
  );
}
setColor("#a855f7");
setText("Spiral: " + points);
console.log("Spiral");
emit();
"""
        ),

        JSScript(
            name: "HEAD TRACK",
            icon: "💀",
            desc: "Đường bám đầu",
            code: """
var hx = 50, hy = 50;
var tx = 80, ty = 30;
for (var i = 0; i <= 30; i++) {
  var t = i / 30;
  var ease = t * t * (3 - 2 * t);
  addPathPoint(
    hx + (tx - hx) * ease,
    hy + (ty - hy) * ease
  );
}
addParticle(tx, ty, 8, 1);
setColor("#ff0033");
setText("Track: 30 điểm");
console.log("Tracked");
emit();
"""
        ),

        JSScript(
            name: "MAGNETIC FIELD",
            icon: "🧲",
            desc: "Trường hút",
            code: """
var cx = 50, cy = 50;
for (var i = 0; i < 50; i++) {
  var a = Math.random() * Math.PI * 2;
  var r = 20 + Math.random() * 40;
  var x = cx + Math.cos(a) * r;
  var y = cy + Math.sin(a) * r;
  var f = (1 - r / 60);
  addParticle(x, y, 3, f);
}
addParticle(cx, cy, 10, 1);
setColor("#00ffff");
setText("Field: 50 hạt");
console.log("Field");
emit();
"""
        ),

        JSScript(
            name: "MATRIX GRID",
            icon: "🟢",
            desc: "Lưới matrix 10x10",
            code: """
for (var i = 0; i < 10; i++) {
  for (var j = 0; j < 10; j++) {
    var x = 5 + i * 10;
    var y = 5 + j * 10;
    var d = Math.sqrt(
      Math.pow(x - 50, 2) +
      Math.pow(y - 50, 2)
    );
    var a = Math.max(0, 1 - d / 60);
    addParticle(x, y, 2, a);
  }
}
setColor("#22c55e");
setText("Matrix: 100 điểm");
console.log("Matrix");
emit();
"""
        ),

        JSScript(
            name: "RECOIL TRAIL",
            icon: "🎚️",
            desc: "Vệt giật súng",
            code: """
var x = 50, y = 60;
for (var i = 0; i < 25; i++) {
  x += (Math.random() - 0.3) * 4;
  y -= 1 + Math.random() * 2;
  addPathPoint(x, y);
  addParticle(x, y, 2 + Math.random() * 2, 0.8);
}
setColor("#ffcc00");
setText("Recoil: 25 shot");
console.log("Recoil");
emit();
"""
        ),

        JSScript(
            name: "PREDICT LEAD",
            icon: "🔮",
            desc: "Dự đoán vị trí",
            code: """
var ex = 30, ey = 70;
var vx = 1.2, vy = -0.6;
var px = ex, py = ey;
for (var i = 0; i < 20; i++) {
  px += vx;
  py += vy;
  addPathPoint(px, py);
}
addParticle(ex, ey, 5, 1);
addParticle(px, py, 8, 1);
setColor("#00d4ff");
setText("Lead: " + px.toFixed(0));
console.log("Lead end " + px.toFixed(1));
emit();
"""
        ),

        JSScript(
            name: "CROSSHAIR WEB",
            icon: "✚",
            desc: "Lưới tâm ảo",
            code: """
var cx = 50, cy = 50;
for (var i = 0; i < 12; i++) {
  var a = (i / 12) * Math.PI * 2;
  addPathPoint(
    cx + Math.cos(a) * 15,
    cy + Math.sin(a) * 15
  );
  addPathPoint(
    cx + Math.cos(a) * 35,
    cy + Math.sin(a) * 35
  );
}
addParticle(cx, cy, 4, 1);
setColor("#ff0033");
setText("Web: 12 spoke");
console.log("Web");
emit();
"""
        ),

        JSScript(
            name: "STAR BURST",
            icon: "⭐",
            desc: "Nổ hình sao",
            code: """
var cx = 50, cy = 50;
var spikes = 8;
for (var i = 0; i < spikes * 2; i++) {
  var a = (i / (spikes * 2)) * Math.PI * 2;
  var r = (i % 2 === 0) ? 40 : 18;
  addPathPoint(
    cx + Math.cos(a) * r,
    cy + Math.sin(a) * r
  );
}
addPathPoint(cx + 40, cy);
addParticle(cx, cy, 6, 1);
setColor("#ffcc00");
setText("Star: " + spikes);
console.log("Star");
emit();
"""
        ),

        JSScript(
            name: "WAVE RIPPLE",
            icon: "💧",
            desc: "Gợn sóng lan",
            code: """
var cx = 50, cy = 50;
for (var ring = 0; ring < 5; ring++) {
  var radius = 5 + ring * 10;
  var steps = 20 + ring * 5;
  for (var i = 0; i < steps; i++) {
    var a = (i / steps) * Math.PI * 2;
    addParticle(
      cx + Math.cos(a) * radius,
      cy + Math.sin(a) * radius,
      2,
      0.9 - ring * 0.15
    );
  }
}
setColor("#0099ff");
setText("Ripple: 5 vòng");
console.log("Ripple");
emit();
"""
        ),

        JSScript(
            name: "DUAL ORBIT",
            icon: "🪐",
            desc: "2 quỹ đạo",
            code: """
var cx = 50, cy = 50;
for (var i = 0; i < 60; i++) {
  var t = (i / 60) * Math.PI * 2;
  addPathPoint(
    cx + Math.cos(t) * 30,
    cy + Math.sin(t) * 30
  );
}
for (var j = 0; j < 40; j++) {
  var t2 = -(j / 40) * Math.PI * 2;
  addParticle(
    cx + Math.cos(t2) * 15,
    cy + Math.sin(t2) * 15,
    3, 0.9
  );
}
setColor("#a855f7");
setText("Dual orbit");
console.log("Orbit");
emit();
"""
        ),

        JSScript(
            name: "FIBONACCI",
            icon: "🌀",
            desc: "Xoắn Fibonacci",
            code: """
var a = 0, b = 1;
var cx = 50, cy = 50;
var angle = 0;
for (var i = 0; i < 15; i++) {
  var r = b * 1.5;
  angle += 0.5;
  var x = cx + Math.cos(angle) * r;
  var y = cy + Math.sin(angle) * r;
  addPathPoint(x, y);
  addParticle(x, y, 3, 0.8);
  var t = a + b;
  a = b;
  b = t;
}
setColor("#ff6b00");
setText("Fib: 15 điểm");
console.log("Fib");
emit();
"""
        ),

        JSScript(
            name: "GRID SCAN",
            icon: "📡",
            desc: "Radar scan",
            code: """
var cx = 50, cy = 50;
for (var r = 5; r < 50; r += 8) {
  var steps = 30;
  for (var i = 0; i < steps; i++) {
    var a = (i / steps) * Math.PI * 2;
    addParticle(
      cx + Math.cos(a) * r,
      cy + Math.sin(a) * r,
      1.5,
      0.8 - r / 80
    );
  }
}
for (var j = 0; j < 40; j++) {
  var r2 = j * 1.2;
  addParticle(
    cx + Math.cos(0.785) * r2,
    cy + Math.sin(0.785) * r2,
    3, 1
  );
}
setColor("#22c55e");
setText("Radar scan");
console.log("Scan");
emit();
"""
        ),

        JSScript(
            name: "HEX GRID",
            icon: "⬡",
            desc: "Lưới lục giác",
            code: """
var cx = 50, cy = 50;
var hexR = 8;
for (var i = 0; i < 8; i++) {
  for (var j = 0; j < 8; j++) {
    var offset = (j % 2) * hexR * 0.866;
    var x = 10 + i * hexR * 1.732 + offset;
    var y = 10 + j * hexR * 1.5;
    if (x > 90 || y > 90) continue;
    for (var k = 0; k < 6; k++) {
      var a = (k / 6) * Math.PI * 2 +
        Math.PI / 6;
      addPathPoint(
        x + Math.cos(a) * hexR * 0.5,
        y + Math.sin(a) * hexR * 0.5
      );
    }
    addParticle(x, y, 1.5, 0.5);
  }
}
setColor("#00ffff");
setText("Hex grid");
console.log("Hex");
emit();
"""
        ),

        JSScript(
            name: "GLITCH",
            icon: "📺",
            desc: "Nhiễu glitch",
            code: """
for (var i = 0; i < 40; i++) {
  var x = Math.random() * 100;
  var y = Math.random() * 100;
  var r = 1 + Math.random() * 4;
  var a = 0.3 + Math.random() * 0.7;
  addParticle(x, y, r, a);
}
for (var j = 0; j < 5; j++) {
  var sx = Math.random() * 100;
  var sy = Math.random() * 100;
  for (var k = 0; k < 20; k++) {
    addPathPoint(sx + k, sy);
  }
}
setColor("#ff0055");
setText("Glitch: 40 pt");
console.log("Glitch");
emit();
"""
        )
    ]
}
