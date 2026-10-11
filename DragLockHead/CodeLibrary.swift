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
            desc: "Khoa muc tieu tu dong",
            language: "C++",
            code: """
// AIMLOCK - Native Plugin
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
            desc: "Nhe tam cam ung muot",
            language: "JavaScript",
            code: """
// MICRO PULL - Touch Smooth
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
            desc: "Bam dau du doan",
            language: "C#",
            code: """
// HEAD TRACK - Unity C#
using UnityEngine;

public class HeadTrackAdvanced
  : MonoBehaviour {

  public float range = 500f;
  public float speed = 12f;
  public float predictTime = 0.15f;
  public LayerMask enemyLayer;

  private Transform head;
  private Vector3 lastPos;
  private Vector3 velocity;
  private Camera cam;

  void Start() {
    cam = Camera.main;
  }

  void Update() {
    if (head == null) FindHead();
    if (head == null) return;

    Vector3 p = Predict(head.position);
    Vector3 d = (
      p - cam.transform.position
    ).normalized;

    cam.transform.rotation = Quaternion.Lerp(
      cam.transform.rotation,
      Quaternion.LookRotation(d),
      Time.deltaTime * speed
    );
  }

  void FindHead() {
    var hits = Physics.OverlapSphere(
      cam.transform.position,
      range,
      enemyLayer
    );
    float best = float.MaxValue;
    Transform bestHead = null;

    foreach (var h in hits) {
      Transform t = FindBone(
        h.transform,
        "head"
      );
      if (t == null) continue;
      float d = Vector3.Distance(
        cam.transform.position,
        t.position
      );
      if (d < best) {
        best = d;
        bestHead = t;
      }
    }
    head = bestHead;
  }

  Vector3 Predict(Vector3 cur) {
    float dt = Time.deltaTime;
    if (dt > 0) {
      velocity = (cur - lastPos) / dt;
    }
    lastPos = cur;
    return cur + velocity * predictTime;
  }

  Transform FindBone(
    Transform root,
    string name
  ) {
    var list = root
      .GetComponentsInChildren<Transform>();
    foreach (Transform t in list) {
      if (
        t.name.ToLower().Contains(name)
      ) return t;
    }
    return null;
  }
}
"""
        ),

        CodeSnippet(
            name: "TOUCH DELAY FIX",
            icon: "4",
            desc: "Khu tre cam ung iOS",
            language: "Swift",
            code: """
// TOUCH DELAY FIX - Swift
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
      let scenes =
        UIApplication.shared.connectedScenes
      for case let sc as UIWindowScene
        in scenes {
        sc.preferredFrameRateRange =
          CAFrameRateRange(
            minimum: 60,
            maximum: 120,
            preferred: 120
          )
      }
    }
  }
}
"""
        ),

        CodeSnippet(
            name: "AIM ASSIST C++",
            icon: "5",
            desc: "Keo muot + du doan",
            language: "C++",
            code: """
// AIM ASSIST - Native Engine
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
    return c + (t - c) * smooth * strength;
  }
};
"""
        ),

        CodeSnippet(
            name: "RECOIL FIX",
            icon: "6",
            desc: "Giam giat sung",
            language: "C#",
            code: """
// RECOIL FIX - Unity
using UnityEngine;

public class RecoilFix
  : MonoBehaviour {

  public float comp = 0.8f;
  public float recovery = 4f;

  private Vector3 acc;
  private Camera cam;

  void Start() {
    cam = Camera.main;
  }

  void LateUpdate() {
    if (acc.magnitude > 0.001f) {
      cam.transform.localRotation *=
        Quaternion.Euler(-acc);
      acc = Vector3.Lerp(
        acc,
        Vector3.zero,
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
            name: "TRIGGER BOT",
            icon: "7",
            desc: "Tu ban khi co target",
            language: "C++",
            code: """
// TRIGGER BOT - Native
#include <chrono>

class TriggerBot {
private:
  float range = 300.0f;
  float interval = 0.02f;
  std::chrono::steady_clock::time_point
    lastCheck;

public:
  bool ShouldFire(
    float cx,
    float cy,
    float cz,
    float fx,
    float fy,
    float fz,
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
            name: "PREDICTION",
            icon: "8",
            desc: "Du doan di chuyen",
            language: "C#",
            code: """
// PREDICTION - Unity
using UnityEngine;

public class Prediction {

  public float leadTime = 0.25f;
  public float smooth = 6f;
  public float maxPred = 8f;

  private Vector3 smoothed;
  private Vector3 lastVel;

  public Vector3 Get(
    Transform target,
    Rigidbody rb
  ) {
    if (rb == null) {
      return target.position;
    }

    Vector3 p =
      target.position
      + rb.velocity * leadTime;

    Vector3 d = p - target.position;

    if (d.magnitude > maxPred) {
      p = target.position
        + d.normalized * maxPred;
    }

    smoothed = Vector3.Lerp(
      smoothed,
      p,
      Time.deltaTime * smooth
    );

    lastVel = rb.velocity;
    return smoothed;
  }
}
"""
        ),

        CodeSnippet(
            name: "FPS BOOST",
            icon: "9",
            desc: "Toi uu hieu nang",
            language: "Swift",
            code: """
// FPS BOOST - Swift
import UIKit
import QuartzCore

class PerformanceBooster {

  static func applyAll() {
    enable120()
    UIApplication.shared
      .isIdleTimerDisabled = true
    optimize()
    URLCache.shared
      .removeAllCachedResponses()
  }

  private static func enable120() {
    if #available(iOS 15.0, *) {
      let scenes =
        UIApplication.shared.connectedScenes
      for case let sc as UIWindowScene
        in scenes {
        sc.preferredFrameRateRange =
          CAFrameRateRange(
            minimum: 60,
            maximum: 120,
            preferred: 120
          )
      }
    }
  }

  private static func optimize() {
    guard let w = UIApplication
      .shared.windows.first
    else { return }
    w.layer.shouldRasterize = true
    w.layer.rasterizationScale =
      UIScreen.main.scale
    w.layer.drawsAsynchronously = true
  }
}
"""
        )
    ]
}

// MARK: - LIBRARY VIEW
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
            Image(systemName: "magnifyingglass")
                .foregroundColor(
                    Color(hex: "9ca3af")
                )
            TextField("Tim code...", text: $query)
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
                value: "\(CodeLibrary.snippets.count)",
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
                .system(size: 18, weight: .black)
            )
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
        VStack(alignment: .leading, spacing: 2) {
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
            Text("\(snippet.code.count)")
                .font(.system(size: 8))
                .foregroundColor(
                    Color(hex: "9ca3af")
                )
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
                Divider()
                    .background(
                        Color.white.opacity(0.1)
                    )
                codeArea
                Divider()
                    .background(
                        Color.white.opacity(0.1)
                    )
                copyButton
            }
        }
    }

    private var headerBar: some View {
        HStack(spacing: 12) {
            Text(snippet.icon)
                .font(
                    .system(
                        size: 20,
                        weight: .black
                    )
                )
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
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
                Image(systemName: "xmark")
                    .font(
                        .system(
                            size: 14,
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
        .background(
            Color.black.opacity(0.6)
        )
    }

    private var copyButton: some View {
        Button(action: doCopy) {
            HStack(spacing: 8) {
                Image(
                    systemName: copied
                        ? "checkmark.circle.fill"
                        : "doc.on.doc.fill"
                )
                Text(
                    copied
                        ? "DA COPY"
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
