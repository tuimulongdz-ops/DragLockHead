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
            name: "AIMLOCK C++",
            icon: "1",
            desc: "Khóa mục tiêu tự động",
            language: "C++",
            code: """
#include <cmath>

struct Vector3 { float x, y, z; };

class AimLock {
public:
  float range = 600.0f;
  float strength = 1.2f;
  float fov = 25.0f;

  Vector3 FindClosest(
    Vector3 cam,
    Vector3 fwd,
    Vector3* enemies,
    int count
  ) {
    float best = 999999.0f;
    Vector3 res = {0, 0, 0};
    for (int i = 0; i < count; i++) {
      Vector3 d = Norm(Sub(enemies[i], cam));
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
  Vector3 Sub(Vector3 a, Vector3 b) {
    return {a.x-b.x, a.y-b.y, a.z-b.z};
  }
  Vector3 Norm(Vector3 v) {
    float l = sqrt(v.x*v.x+v.y*v.y+v.z*v.z);
    if (l == 0) return v;
    return {v.x/l, v.y/l, v.z/l};
  }
  float Dist(Vector3 a, Vector3 b) {
    Vector3 d = Sub(a, b);
    return sqrt(d.x*d.x+d.y*d.y+d.z*d.z);
  }
  float Angle(Vector3 a, Vector3 b) {
    float dot = a.x*b.x+a.y*b.y+a.z*b.z;
    return acos(dot) * 57.2958f;
  }
};
"""
        ),

        CodeSnippet(
            name: "MICRO PULL JS",
            icon: "2",
            desc: "Nhẹ tâm cảm ứng mượt",
            language: "JavaScript",
            code: """
(function() {
  let lastX = 0;
  let lastY = 0;
  const SMOOTH = 0.85;
  const THROTTLE = 8;
  let lastTime = 0;

  document.addEventListener(
    'touchmove',
    function(e) {
      const now = performance.now();
      if (now - lastTime < THROTTLE) return;
      lastTime = now;
      const t = e.touches[0];
      if (!t) return;
      lastX = lastX + (t.clientX - lastX) * SMOOTH;
      lastY = lastY + (t.clientY - lastY) * SMOOTH;
      const el = e.target;
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
            name: "HEAD TRACK C#",
            icon: "3",
            desc: "Bám đầu dự đoán",
            language: "C#",
            code: """
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
      Time.deltaTime * speed);
  }

  void Find() {
    var hits = Physics.OverlapSphere(
      cam.transform.position,
      range,
      enemyLayer);
    float best = float.MaxValue;
    Transform bt = null;
    foreach (var h in hits) {
      var t = FindBone(h.transform, "head");
      if (t == null) continue;
      float d = Vector3.Distance(
        cam.transform.position,
        t.position);
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
            name: "TOUCH DELAY FIX",
            icon: "4",
            desc: "Khử trễ cảm ứng iOS",
            language: "Swift",
            code: """
import UIKit

class TouchOptimizer {
  static func applyTo(_ view: UIView) {
    view.isMultipleTouchEnabled = true
    view.isExclusiveTouch = false
    for sub in view.subviews {
      sub.isUserInteractionEnabled = true
      if let s = sub as? UIScrollView {
        s.delaysContentTouches = false
        s.canCancelContentTouches = true
      }
    }
  }

  static func enable120Hz() {
    if #available(iOS 15.0, *) {
      let scenes = UIApplication.shared
        .connectedScenes;
      for case let sc as UIWindowScene in scenes {
        sc.preferredFrameRateRange =
          CAFrameRateRange(
            minimum: 60,
            maximum: 120,
            preferred: 120);
      }
    }
  }
}
"""
        ),

        CodeSnippet(
            name: "AIM ASSIST C++",
            icon: "5",
            desc: "Kéo mượt + dự đoán",
            language: "C++",
            code: """
#include <cmath>
#include <algorithm>

class AimAssist {
private:
  float range = 600.0f;
  float smooth = 0.08f;
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
    float cx,
    float cy,
    float cz
  ) {
    Target best = {0,0,0,0,0,0};
    float bd = 999999.0f;
    for (int i = 0; i < count; i++) {
      float dx = enemies[i].x - cx;
      float dy = enemies[i].y - cy;
      float dz = enemies[i].z - cz;
      float d = sqrt(dx*dx + dy*dy + dz*dz);
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
    return c + (t - c) * smooth * strength;
  }
};
"""
        ),

        CodeSnippet(
            name: "RECOIL FIX",
            icon: "6",
            desc: "Giảm giật súng",
            language: "C#",
            code: """
using UnityEngine;

public class RecoilFix : MonoBehaviour {
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
        acc,
        Vector3.zero,
        Time.deltaTime * recovery);
    }
  }

  public void OnShoot() {
    Vector3 r = new Vector3(
      Random.Range(-0.5f, 0.5f),
      Random.Range(0.5f, 1.5f),
      0) * comp;
    acc += r;
  }
}
"""
        ),

        CodeSnippet(
            name: "TRIGGER BOT",
            icon: "7",
            desc: "Tự bắn khi có target",
            language: "C++",
            code: """
#include <chrono>

class TriggerBot {
private:
  float range = 300.0f;
  float interval = 0.02f;
  std::chrono::steady_clock::time_point
    lastCheck;

public:
  bool ShouldFire(
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
      float d = sqrt(dx*dx + dy*dy + dz*dz);
      if (d > range) continue;
      float dot = (dx*fx + dy*fy + dz*fz) / d;
      if (dot > 0.98f) return true;
    }
    return false;
  }
};
"""
        ),

        CodeSnippet(
            name: "PREDICTION",
            icon: "8",
            desc: "Dự đoán di chuyển địch",
            language: "C#",
            code: """
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
    if (rb == null) return target.position;
    Vector3 p = target.position
      + rb.velocity * leadTime;
    Vector3 d = p - target.position;
    if (d.magnitude > maxPred) {
      p = target.position
        + d.normalized * maxPred;
    }
    smoothed = Vector3.Lerp(
      smoothed, p,
      Time.deltaTime * smooth);
    lastVel = rb.velocity;
    return smoothed;
  }
}
"""
        ),

        CodeSnippet(
            name: "FPS BOOST",
            icon: "9",
            desc: "Tối ưu hiệu năng iOS",
            language: "Swift",
            code: """
import UIKit
import QuartzCore

class PerformanceBooster {
  static func applyAll() {
    enable120Hz()
    UIApplication.shared
      .isIdleTimerDisabled = true
    optimizeLayers()
    URLCache.shared
      .removeAllCachedResponses()
  }

  private static func enable120Hz() {
    if #available(iOS 15.0, *) {
      let scenes = UIApplication.shared
        .connectedScenes;
      for case let sc as UIWindowScene in scenes {
        sc.preferredFrameRateRange =
          CAFrameRateRange(
            minimum: 60,
            maximum: 120,
            preferred: 120);
      }
    }
  }

  private static func optimizeLayers() {
    guard let w = UIApplication.shared
      .windows.first else { return }
    w.layer.shouldRasterize = true
    w.layer.rasterizationScale =
      UIScreen.main.scale
    w.layer.drawsAsynchronously = true
  }
}
"""
        ),

        CodeSnippet(
            name: "AIM DATA CORE",
            icon: "A",
            desc: "Core algorithm v1.2",
            language: "C++",
            code: """
#include <cmath>
#include <cstring>
#include <cstdio>
#include <cstdlib>

#define DAT_MAGIC 0xA7C3F1E2

struct AimData {
  uint32_t magic;
  float sensitivity;
  float smoothAlpha;
  float gateThresh;
  float jerkThresh;
  float jerkDamp;
  float emaAlpha;
  float lockRadius;
  float pullStrength;
  float snapStrength;
};

struct AimState {
  AimData cfg;
  float vx, vy;
  bool init;
  float lastX, lastY;
  float subPx, subPy;
  float noiseEst;
  bool active;
};

bool Aim_Load(AimState *s, const char *path) {
  if (!s || !path) return false;
  FILE *f = fopen(path, "rb");
  if (!f) return false;
  AimData d;
  size_t n = fread(&d, 1, sizeof(AimData), f);
  fclose(f);
  if (n != sizeof(AimData)) return false;
  if (d.magic != DAT_MAGIC) return false;
  memset(s, 0, sizeof(AimState));
  s->cfg = d;
  return true;
}

void Aim_SaveDefault(const char *path) {
  AimData d;
  memset(&d, 0, sizeof(AimData));
  d.magic = DAT_MAGIC;
  d.sensitivity = 2.5f;
  d.smoothAlpha = 0.45f;
  d.gateThresh = 0.9f;
  d.jerkThresh = 6.0f;
  d.jerkDamp = 0.5f;
  d.emaAlpha = 0.45f;
  d.lockRadius = 80.f;
  d.pullStrength = 0.35f;
  d.snapStrength = 0.6f;
  FILE *f = fopen(path, "wb");
  if (!f) return;
  fwrite(&d, 1, sizeof(AimData), f);
  fclose(f);
}
"""
        ),

        CodeSnippet(
            name: "MOVE TOWARDS",
            icon: "B",
            desc: "Di chuyển tâm cơ bản",
            language: "C++",
            code: """
#include <iostream>
#include <cmath>
#include <thread>
#include <chrono>

struct Vector2 {
  float x;
  float y;
};

float Distance(
  const Vector2& a,
  const Vector2& b
) {
  float dx = b.x - a.x;
  float dy = b.y - a.y;
  return std::sqrt(dx * dx + dy * dy);
}

void MoveTowards(
  Vector2& current,
  const Vector2& target,
  float speed
) {
  float dx = target.x - current.x;
  float dy = target.y - current.y;
  float dist = std::sqrt(dx * dx + dy * dy);
  if (dist <= speed || dist == 0.0f) {
    current = target;
    return;
  }
  current.x += (dx / dist) * speed;
  current.y += (dy / dist) * speed;
}

int main() {
  Vector2 crosshair{0.0f, 0.0f};
  Vector2 target{250.0f, 150.0f};
  while (Distance(crosshair, target) > 0.1f) {
    MoveTowards(crosshair, target, 5.0f);
    std::cout << crosshair.x << " "
              << crosshair.y << "\\n";
    std::this_thread::sleep_for(
      std::chrono::milliseconds(16));
  }
  return 0;
}
"""
        ),

        CodeSnippet(
            name: "BONE SCANNER",
            icon: "C",
            desc: "Bone data từ game",
            language: "Unity",
            code: """
Bone List:
  bone_Hips         / Core Bone
  bone_Hips_Dummy   / Attach
  bone_Spine        / Core Bone
  bone_Spine1       / Core Bone
  bone_Neck         / Core Bone
  bone_Head         / CORE HEAD
  bone_Mask         / Mesh
  bone_Hat          / Attach
  bone_Glasses      / Attach

  bone_LeftClav     / Shoulder
  bone_LeftArm      / Upper Arm
  bone_LeftForeArm  / Lower Arm
  bone_LeftHand     / Hand
  bone_LeftThumb1   / Finger
  bone_LeftThumb2   / Finger
  bone_LeftIndex1   / Finger
  bone_LeftIndex2   / Finger
  bone_LeftMiddle1  / Finger
  bone_LeftMiddle2  / Finger
  bone_LeftLegUpper / Thigh
  bone_LeftLeg      / Shin
  bone_LeftAnkle    / Ankle
  bone_LeftToe      / Foot

  bone_RightClav    / Shoulder
  bone_RightArm     / Upper Arm
  bone_RightForeArm / Lower Arm
  bone_RightHand    / Hand
  bone_RightThumb1  / Finger
  bone_RightThumb2  / Finger
  bone_RightIndex1  / Finger
  bone_RightIndex2  / Finger
  bone_RightMiddle1 / Finger
  bone_RightMiddle2 / Finger
  bone_RightLegUpper / Thigh
  bone_RightLeg     / Shin
  bone_RightAnkle   / Ankle
  bone_RightToe     / Foot

Collider Classes:
  SABoneCollider
  CapsuleHumanSniperCollider
  Male_DTSCollider
  Female_DTSCollider
  HitDetectColliderHelper
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
                    query)
            || $0.language
                .localizedCaseInsensitiveContains(
                    query)
        }
    }

    var body: some View {
        VStack(spacing: 10) {
            searchBar
            statsRow
            SectionTitle(
                text: "CODE - \(list.count)"
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
            Text("🔍").font(.system(size: 14))
            TextField("Tim code...", text: $query)
                .foregroundColor(.white)
                .disableAutocorrection(true)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.045))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    Color.white.opacity(0.1),
                    lineWidth: 1)
        )
    }

    private var statsRow: some View {
        HStack(spacing: 8) {
            StatBox(
                value: "\(CodeLibrary.snippets.count)",
                label: "SNIPPETS")
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
                .font(.system(size: 14, weight: .black))
                .foregroundColor(Color(hex: "00d4ff"))
            Text(label)
                .font(.system(size: 8, weight: .heavy))
                .foregroundColor(Color(hex: "9ca3af"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.045))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(
                    Color.white.opacity(0.1),
                    lineWidth: 1)
        )
    }
}

struct CodeCard: View {
    let snippet: CodeSnippet
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                Text(snippet.icon)
                    .font(.system(size: 18, weight: .black))
                    .foregroundColor(.white)
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
                            endPoint: .bottomTrailing)
                    )
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                Color(hex: "00d4ff")
                                    .opacity(0.3),
                                lineWidth: 1)
                    )
                VStack(
                    alignment: .leading,
                    spacing: 2
                ) {
                    Text(snippet.name)
                        .font(.system(
                            size: 12.5,
                            weight: .black))
                        .foregroundColor(.white)
                    Text(snippet.desc)
                        .font(.system(size: 10))
                        .foregroundColor(
                            Color(hex: "9ca3af"))
                }
                Spacer()
                Text(snippet.language)
                    .font(.system(size: 9, weight: .heavy))
                    .foregroundColor(Color(hex: "00d4ff"))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Color(hex: "0099ff").opacity(0.2))
                    .cornerRadius(6)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.03))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        Color.white.opacity(0.08),
                        lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct CodeDetailView: View {
    let snippet: CodeSnippet
    @State private var copied: Bool = false
    @Environment(\.presentationMode)
    var presentationMode

    var body: some View {
        ZStack {
            Color(hex: "06080d").ignoresSafeArea()
            VStack(spacing: 0) {
                header
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 1)
                codeArea
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 1)
                copyBtn
            }
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            Text(snippet.icon)
                .font(.system(size: 20, weight: .black))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(
                    LinearGradient(
                        colors: [
                            Color(hex: "0099ff"),
                            Color(hex: "00d4ff")
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing)
                )
                .cornerRadius(10)
            VStack(alignment: .leading, spacing: 2) {
                Text(snippet.name)
                    .font(.system(
                        size: 15,
                        weight: .black))
                    .foregroundColor(.white)
                Text(snippet.language)
                    .font(.system(
                        size: 10,
                        weight: .heavy))
                    .foregroundColor(
                        Color(hex: "00d4ff"))
            }
            Spacer()
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("✕")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(
                        Color.white.opacity(0.1))
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
                .font(.system(
                    size: 11,
                    design: .monospaced))
                .foregroundColor(Color(hex: "00d4ff"))
                .padding(16)
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity)
        .background(Color.black.opacity(0.6))
    }

    private var copyBtn: some View {
        Button(action: {
            UIPasteboard.general.string = snippet.code
            copied = true
            UIImpactFeedbackGenerator(
                style: .medium
            ).impactOccurred()
            DispatchQueue.main.asyncAfter(
                deadline: .now() + 1.5
            ) {
                copied = false
            }
        }) {
            HStack(spacing: 8) {
                Text(copied ? "✓" : "📋")
                Text(copied ? "ĐÃ COPY" : "COPY CODE")
                    .font(.system(
                        size: 13,
                        weight: .black))
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
                    endPoint: .trailing)
            )
            .cornerRadius(12)
        }
        .padding(16)
        .background(Color(hex: "0d1117"))
    }
}
