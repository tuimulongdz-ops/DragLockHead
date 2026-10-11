import SwiftUI

struct CodeSnippet: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let desc: String
    let language: String
    let code: String
}

struct CodeLibrary {
    static let snippets: [CodeSnippet] = [
        CodeSnippet(
            name: "NHẸ TÂM",
            icon: "👆",
            desc: "Micro pull chuẩn xác",
            language: "JavaScript",
            code: """
// MICRO PULL - Touch Smooth
(function() {
  var lastX = 0, lastY = 0;
  var SMOOTH = 0.85;
  var THROTTLE = 8;
  var lastTime = 0;

  document.addEventListener(
    'touchmove',
    function(e) {
      var now = performance.now();
      if (now - lastTime < THROTTLE) return;
      lastTime = now;

      var t = e.touches[0];
      if (!t) return;

      lastX += (t.clientX - lastX) * SMOOTH;
      lastY += (t.clientY - lastY) * SMOOTH;

      var el = e.target;
      if (el && el.style) {
        el.style.transform =
          'translate(' + lastX + 'px,' +
          lastY + 'px)';
      }
    },
    { passive: true }
  );
})();
"""
        ),
        CodeSnippet(
            name: "BÁM ĐẦU",
            icon: "💀",
            desc: "Head tracking dự đoán",
            language: "C#",
            code: """
// HEAD TRACK - Unity C#
using UnityEngine;

public class HeadTrack : MonoBehaviour {
  public float range = 500f;
  public float speed = 12f;
  public float predictTime = 0.15f;
  public LayerMask enemyLayer;

  Transform head;
  Vector3 lastPos;
  Vector3 velocity;
  Camera cam;

  void Start() { cam = Camera.main; }

  void Update() {
    if (head == null) Find();
    if (head == null) return;

    Vector3 p = Predict(head.position);
    Vector3 d = (p - cam.transform.position)
      .normalized;

    cam.transform.rotation = Quaternion.Lerp(
      cam.transform.rotation,
      Quaternion.LookRotation(d),
      Time.deltaTime * speed
    );
  }

  void Find() {
    var hits = Physics.OverlapSphere(
      cam.transform.position,
      range,
      enemyLayer
    );
    float best = float.MaxValue;
    Transform bt = null;

    foreach (var h in hits) {
      var t = FindBone(h.transform, "head");
      if (t == null) continue;
      float d = Vector3.Distance(
        cam.transform.position,
        t.position
      );
      if (d < best) { best = d; bt = t; }
    }
    head = bt;
  }

  Vector3 Predict(Vector3 cur) {
    float dt = Time.deltaTime;
    if (dt > 0)
      velocity = (cur - lastPos) / dt;
    lastPos = cur;
    return cur + velocity * predictTime;
  }

  Transform FindBone(Transform root, string n) {
    var list = root
      .GetComponentsInChildren<Transform>();
    foreach (Transform t in list) {
      if (t.name.ToLower().Contains(n))
        return t;
    }
    return null;
  }
}
"""
        ),
        CodeSnippet(
            name: "DRAG AIM",
            icon: "🎯",
            desc: "Kéo aim theo ngón tay",
            language: "C++",
            code: """
// DRAG AIM - Native C++
#include <cmath>

struct Vec3 { float x, y, z; };

class DragAim {
public:
  float pullRange = 200.0f;
  float pullForce = 0.6f;

  Vec3 Update(
    Vec3 aimDir,
    Vec3 touchDir,
    float dist
  ) {
    if (dist > pullRange) return aimDir;

    float strength =
      (1.0f - dist / pullRange)
      * pullForce;

    Vec3 result;
    result.x = aimDir.x +
      (touchDir.x - aimDir.x) * strength;
    result.y = aimDir.y +
      (touchDir.y - aimDir.y) * strength;
    result.z = aimDir.z +
      (touchDir.z - aimDir.z) * strength;

    return Normalize(result);
  }

private:
  Vec3 Normalize(Vec3 v) {
    float l = sqrt(
      v.x*v.x + v.y*v.y + v.z*v.z
    );
    if (l == 0) return v;
    return {v.x/l, v.y/l, v.z/l};
  }
};
"""
        ),
        CodeSnippet(
            name: "AIM ASSIST",
            icon: "🌀",
            desc: "Kéo mượt + dự đoán",
            language: "C++",
            code: """
// AIM ASSIST - Native Engine
#include <cmath>

class AimAssist {
private:
  float range = 600.0f;
  float smoothness = 0.08f;
  float strength = 1.2f;
  float leadTime = 0.12f;

public:
  struct Target {
    float x, y, z;
    float vx, vy, vz;
  };

  Target Calc(
    Target* enemies,
    int count,
    float cx, float cy, float cz
  ) {
    Target best = {0,0,0,0,0,0};
    float bd = 999999.0f;

    for (int i = 0; i < count; i++) {
      float dx = enemies[i].x - cx;
      float dy = enemies[i].y - cy;
      float dz = enemies[i].z - cz;
      float d = sqrt(
        dx*dx + dy*dy + dz*dz
      );
      if (d > range) continue;
      if (d < bd) {
        bd = d;
        best = enemies[i];
      }
    }

    best.x += best.vx * leadTime;
    best.y += best.vy * leadTime;
    best.z += best.vz * leadTime;
    return best;
  }

  float Smooth(float c, float t) {
    return c + (t - c) * smoothness
      * strength;
  }
};
"""
        ),
        CodeSnippet(
            name: "PREDICTION",
            icon: "🔮",
            desc: "Dự đoán di chuyển địch",
            language: "C#",
            code: """
// PREDICTION - Unity
using UnityEngine;

public class Prediction {
  public float leadTime = 0.25f;
  public float smooth = 6f;
  public float maxPred = 8f;

  Vector3 smoothed;
  Vector3 lastVel;

  public Vector3 Get(
    Transform target,
    Rigidbody rb
  ) {
    if (rb == null)
      return target.position;

    Vector3 p = target.position
      + rb.velocity * leadTime;
    Vector3 d = p - target.position;

    if (d.magnitude > maxPred) {
      p = target.position
        + d.normalized * maxPred;
    }

    smoothed = Vector3.Lerp(
      smoothed, p,
      Time.deltaTime * smooth
    );

    lastVel = rb.velocity;
    return smoothed;
  }
}
"""
        ),
        CodeSnippet(
            name: "SMOOTH TARGET",
            icon: "🌊",
            desc: "Chuyển mục tiêu mượt",
            language: "Swift",
            code: """
// SMOOTH TARGET - Swift
import Foundation
import simd

class SmoothTarget {
  var switchSpeed: Float = 8.0
  var maxDelta: Float = 0.15
  var holdTime: Float = 0.5

  private var target: simd_float3?
  private var smoothDir = simd_float3()
  private var lastSwitch: Float = 0

  func update(
    targetPos: simd_float3,
    currentPos: simd_float3,
    dt: Float
  ) -> simd_float3 {
    let td = simd_normalize(
      targetPos - currentPos
    )
    smoothDir = simd_slerp(
      smoothDir, td,
      dt * switchSpeed
    )

    let maxRad = maxDelta * 360.0 * dt
    return simd_clamp(
      smoothDir,
      -maxRad, maxRad
    )
  }
}
"""
        ),
        CodeSnippet(
            name: "AIM LOCK",
            icon: "🔒",
            desc: "Khóa mục tiêu tự động",
            language: "C++",
            code: """
// AIM LOCK - Native
#include <cmath>

struct V3 { float x, y, z; };

class AimLock {
public:
  float range = 600.0f;
  float strength = 1.2f;
  float fov = 25.0f;

  V3 Find(
    V3 cam,
    V3 fwd,
    V3* enemies,
    int count
  ) {
    float best = 999999.0f;
    V3 res = {0, 0, 0};

    for (int i = 0; i < count; i++) {
      V3 d = Norm(Sub(enemies[i], cam));
      float a = Angle(fwd, d);
      if (a > fov) continue;
      float dist = Dist(cam, enemies[i]);
      float s = dist + a * 2.0f;
      if (s < best) {
        best = s;
        res = enemies[i];
      }
    }
    return res;
  }

private:
  V3 Sub(V3 a, V3 b) {
    return {a.x-b.x, a.y-b.y, a.z-b.z};
  }
  V3 Norm(V3 v) {
    float l = sqrt(
      v.x*v.x + v.y*v.y + v.z*v.z
    );
    if (l == 0) return v;
    return {v.x/l, v.y/l, v.z/l};
  }
  float Dist(V3 a, V3 b) {
    V3 d = Sub(a, b);
    return sqrt(
      d.x*d.x + d.y*d.y + d.z*d.z
    );
  }
  float Angle(V3 a, V3 b) {
    float dot = a.x*b.x + a.y*b.y
      + a.z*b.z;
    return acos(dot) * 57.2958f;
  }
};
"""
        ),
        CodeSnippet(
            name: "TRIGGER BOT",
            icon: "⚡",
            desc: "Tự bắn khi có mục tiêu",
            language: "C++",
            code: """
// TRIGGER BOT - Native
#include <cmath>
#include <chrono>

class TriggerBot {
private:
  float range = 300.0f;
  float interval = 0.02f;
  std::chrono::steady_clock::time_point
    lastCheck;

public:
  bool Fire(
    float cx, float cy, float cz,
    float fx, float fy, float fz,
    float* enemies,
    int count
  ) {
    auto now = std::chrono::steady_clock
      ::now();
    auto dt = std::chrono::duration<float>(
      now - lastCheck
    ).count();

    if (dt < interval) return false;
    lastCheck = now;

    for (int i = 0; i < count; i++) {
      float ex = enemies[i * 3];
      float ey = enemies[i * 3 + 1];
      float ez = enemies[i * 3 + 2];

      float dx = ex - cx;
      float dy = ey - cy;
      float dz = ez - cz;
      float d = sqrt(
        dx*dx + dy*dy + dz*dz
      );
      if (d > range) continue;

      float dot = (
        dx*fx + dy*fy + dz*fz
      ) / d;
      if (dot > 0.98f) return true;
    }
    return false;
  }
};
"""
        ),
        CodeSnippet(
            name: "RECOIL FIX",
            icon: "🎚️",
            desc: "Giảm giật súng",
            language: "C#",
            code: """
// RECOIL FIX - Unity
using UnityEngine;

public class RecoilFix
  : MonoBehaviour {
  public float comp = 0.8f;
  public float recovery = 4f;

  Vector3 acc;
  Camera cam;

  void Start() { cam = Camera.main; }

  void LateUpdate() {
    if (acc.magnitude > 0.001f) {
      cam.transform.localRotation *=
        Quaternion.Euler(-acc);
      acc = Vector3.Lerp(
        acc, Vector3.zero,
        Time.deltaTime * recovery
      );
    }
  }

  public void OnShoot() {
    Vector3 r = new Vector3(
      Random.Range(-0.5f, 0.5f),
      Random.Range(0.5f, 1.5f),
      0
    ) * comp;
    acc += r;
  }
}
"""
        ),
        CodeSnippet(
            name: "NO SPREAD",
            icon: "🎯",
            desc: "Không tản mác đạn",
            language: "Swift",
            code: """
// NO SPREAD - Swift
import Foundation
import simd

class NoSpread {
  var enabled = true
  var multiplier: Float = 0.0

  func apply(
    spread: simd_float3
  ) -> simd_float3 {
    if !enabled { return spread }
    return spread * multiplier
  }

  func onShoot(
    weaponRot: simd_quatf
  ) -> simd_quatf {
    // Reset weapon rotation về
    // trạng thái chính xác
    var r = weaponRot
    r = simd_quatf(ix: 0, iy: 0,
      iz: 0, r: 1)
    return r
  }
}
"""
        ),
        CodeSnippet(
            name: "SILENT AIM",
            icon: "🤫",
            desc: "Ngắm không lộ",
            language: "C++",
            code: """
// SILENT AIM - Native
#include <cmath>

class SilentAim {
private:
  float range = 600.0f;

public:
  struct Target {
    float x, y, z;
  };

  // Trả về hướng aim thật
  // nhưng không hiển thị trên
  // màn hình user
  Target GetSilentDir(
    Target cam,
    Target* enemies,
    int count
  ) {
    Target best = {0, 0, 0};
    float bd = 999999.0f;

    for (int i = 0; i < count; i++) {
      float dx = enemies[i].x - cam.x;
      float dy = enemies[i].y - cam.y;
      float dz = enemies[i].z - cam.z;
      float d = sqrt(
        dx*dx + dy*dy + dz*dz
      );
      if (d < bd) {
        bd = d;
        best = enemies[i];
      }
    }
    return best;
  }
};
"""
        ),
        CodeSnippet(
            name: "FLICK AIM",
            icon: "💫",
            desc: "Bật tâm tức thời",
            language: "C++",
            code: """
// FLICK AIM - Native
#include <cmath>
#include <chrono>

class FlickAim {
private:
  float speed = 25.0f;
  float flickTime = 0.15f;
  float startX = 0, startY = 0;
  float targetX = 0, targetY = 0;
  bool active = false;
  std::chrono::steady_clock::time_point
    start;

public:
  void Flick(float tx, float ty) {
    targetX = tx;
    targetY = ty;
    start = std::chrono::steady_clock::now();
    active = true;
  }

  bool Update(float& outX, float& outY) {
    if (!active) return false;

    auto now = std::chrono::steady_clock
      ::now();
    float dt = std::chrono::duration<float>(
      now - start
    ).count();
    float t = dt / flickTime;
    if (t >= 1.0f) {
      active = false;
      outX = targetX;
      outY = targetY;
      return false;
    }

    float ease = 1.0f - pow(1.0f - t, 3);
    outX = startX +
      (targetX - startX) * ease;
    outY = startY +
      (targetY - startY) * ease;
    return true;
  }
};
"""
        ),
        CodeSnippet(
            name: "QUICK SCOPE",
            icon: "🔭",
            desc: "Ngắm nhanh scope",
            language: "C#",
            code: """
// QUICK SCOPE - Unity
using UnityEngine;

public class QuickScope
  : MonoBehaviour {

  public float scopeTime = 0.15f;
  float scopeStart;

  public void OnScopePress() {
    scopeStart = Time.time;
  }

  public bool IsScoped() {
    return Time.time - scopeStart
      < scopeTime;
  }

  public float ScopeProgress() {
    return Mathf.Clamp01(
      (Time.time - scopeStart)
        / scopeTime
    );
  }
}
"""
        ),
        CodeSnippet(
            name: "BURST LOCK",
            icon: "🔥",
            desc: "Khóa loạt đạn",
            language: "C#",
            code: """
// BURST LOCK - Unity
using UnityEngine;

public class BurstLock
  : MonoBehaviour {

  public int burstCount = 3;
  public float burstDelay = 0.08f;

  int current;
  float lastShot;

  public bool OnShoot() {
    if (Time.time - lastShot
      < burstDelay) return false;

    lastShot = Time.time;
    current++;
    if (current >= burstCount) {
      current = 0;
    }
    return current > 0;
  }

  public bool IsLocked() {
    return current > 0;
  }
}
"""
        ),
        CodeSnippet(
            name: "FAST SWAP",
            icon: "⚡",
            desc: "Đổi súng nhanh",
            language: "C#",
            code: """
// FAST SWAP - Unity
using UnityEngine;

public class FastSwap
  : MonoBehaviour {

  public float swapDelay = 0.05f;
  int currentSlot;
  float lastSwap;

  public void Swap(int slot) {
    if (Time.time - lastSwap
      < swapDelay) return;

    lastSwap = Time.time;
    currentSlot = slot;

    var anim = GetComponent<Animator>();
    if (anim != null) {
      anim.speed = 100f;
      anim.Play("SwitchWeapon", 0, 1f);
    }
  }

  public int CurrentSlot() {
    return currentSlot;
  }
}
"""
        )
    ]
}

struct CodeLibraryView: View {

    @State private var selected: CodeSnippet?
    @State private var query: String = ""

    private var list: [CodeSnippet] {
        if query.isEmpty {
            return CodeLibrary.snippets
        }
        return CodeLibrary.snippets.filter {
            $0.name
                .localizedCaseInsensitiveContains(
                    query
                )
            || $0.language
                .localizedCaseInsensitiveContains(
                    query
                )
        }
    }

    var body: some View {
        VStack(spacing: 10) {
            searchBar
            statsRow
            SectionTitle(
                text: "CODE LIBRARY - \(list.count)"
            )
            ForEach(list) { s in
                CodeCard(snippet: s) {
                    selected = s
                }
            }
        }
        .sheet(item: $selected) { s in
            CodeDetailView(snippet: s)
        }
    }

    private var searchBar: some View {
        HStack(spacing: 8) {
            Text("🔍")
                .font(.system(size: 14))
            TextField(
                "Tim code...",
                text: $query
            )
            .foregroundColor(.white)
            .disableAutocorrection(true)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            Color.white.opacity(0.045)
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    Color.white.opacity(0.1),
                    lineWidth: 1
                )
        )
    }

    private var statsRow: some View {
        HStack(spacing: 8) {
            StatBox(
                value:
                    "\(CodeLibrary.snippets.count)",
                label: "SNIPPETS"
            )
            StatBox(value: "5", label: "NGON NGU")
            StatBox(value: "PRO", label: "TIER")
        }
    }
}

struct StatBox: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(
                    .system(
                        size: 14,
                        weight: .black
                    )
                )
                .foregroundColor(
                    Color(hex: "00d4ff")
                )
            Text(label)
                .font(
                    .system(
                        size: 8,
                        weight: .heavy
                    )
                )
                .foregroundColor(
                    Color(hex: "9ca3af")
                )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            Color.white.opacity(0.045)
        )
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(
                    Color.white.opacity(0.1),
                    lineWidth: 1
                )
        )
    }
}

struct CodeCard: View {
    let snippet: CodeSnippet
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                iconView
                textView
                Spacer()
                tagView
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                Color.white.opacity(0.03)
            )
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        Color.white.opacity(0.08),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private var iconView: some View {
        Text(snippet.icon)
            .font(
                .system(size: 20)
            )
            .frame(width: 42, height: 42)
            .background(
                LinearGradient(
                    colors: [
                        Color(hex: "0099ff")
                            .opacity(0.6),
                        Color(hex: "00d4ff")
                            .opacity(0.3)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        Color(hex: "00d4ff")
                            .opacity(0.3),
                        lineWidth: 1
                    )
            )
    }

    private var textView: some View {
        VStack(
            alignment: .leading,
            spacing: 2
        ) {
            Text(snippet.name)
                .font(
                    .system(
                        size: 12.5,
                        weight: .black
                    )
                )
                .foregroundColor(.white)
            Text(snippet.desc)
                .font(.system(size: 10))
                .foregroundColor(
                    Color(hex: "9ca3af")
                )
        }
    }

    private var tagView: some View {
        VStack(spacing: 2) {
            Text(snippet.language)
                .font(
                    .system(
                        size: 9,
                        weight: .heavy
                    )
                )
                .foregroundColor(
                    Color(hex: "00d4ff")
                )
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Color(hex: "0099ff")
                        .opacity(0.2)
                )
                .cornerRadius(6)
        }
    }
}

struct CodeDetailView: View {
    let snippet: CodeSnippet
    @State private var copied: Bool = false
    @Environment(\.presentationMode)
    var presentationMode

    var body: some View {
        ZStack {
            Color(hex: "06080d")
                .ignoresSafeArea()
            VStack(spacing: 0) {
                headerBar
                divider
                codeArea
                divider
                copyButton
            }
        }
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.1))
            .frame(height: 1)
    }

    private var headerBar: some View {
        HStack(spacing: 12) {
            Text(snippet.icon)
                .font(.system(size: 24))
                .frame(width: 44, height: 44)
                .background(
                    LinearGradient(
                        colors: [
                            Color(hex: "0099ff"),
                            Color(hex: "00d4ff")
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(10)

            VStack(
                alignment: .leading,
                spacing: 2
            ) {
                Text(snippet.name)
                    .font(
                        .system(
                            size: 15,
                            weight: .black
                        )
                    )
                    .foregroundColor(.white)
                Text(snippet.language)
                    .font(
                        .system(
                            size: 10,
                            weight: .heavy
                        )
                    )
                    .foregroundColor(
                        Color(hex: "00d4ff")
                    )
            }

            Spacer()

            Button(action: dismiss) {
                Text("✕")
                    .font(
                        .system(
                            size: 16,
                            weight: .bold
                        )
                    )
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(
                        Color.white.opacity(0.1)
                    )
                    .cornerRadius(10)
            }
        }
        .padding(16)
        .background(Color(hex: "0d1117"))
    }

    private var codeArea: some View {
        ScrollView(
            [.vertical, .horizontal],
            showsIndicators: false
        ) {
            Text(snippet.code)
                .font(
                    .system(
                        size: 11,
                        design: .monospaced
                    )
                )
                .foregroundColor(
                    Color(hex: "00d4ff")
                )
                .padding(16)
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
        .background(Color.black.opacity(0.6))
    }

    private var copyButton: some View {
        Button(action: doCopy) {
            HStack(spacing: 8) {
                Text(copied ? "✓" : "📋")
                    .font(.system(size: 14))
                Text(
                    copied
                        ? "ĐÃ COPY"
                        : "COPY CODE"
                )
                .font(
                    .system(
                        size: 13,
                        weight: .black
                    )
                )
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(
                LinearGradient(
                    colors: [
                        Color(hex: "0099ff"),
                        Color(hex: "00d4ff")
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
        }
        .padding(16)
        .background(Color(hex: "0d1117"))
    }

    private func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }

    private func doCopy() {
        UIPasteboard.general.string =
            snippet.code
        copied = true
        UIImpactFeedbackGenerator(
            style: .medium
        ).impactOccurred()

        DispatchQueue.main.asyncAfter(
            deadline: .now() + 1.5
        ) {
            copied = false
        }
    }
}
