import SwiftUI

struct CodeSnippet: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let description: String
    let language: String
    let code: String
}

struct CodeLibrary {
    static let snippets: [CodeSnippet] = [
        CodeSnippet(
            name: "AIMLOCK C++",
            icon: "1",
            description: "Khoa muc tieu tu dong",
            language: "C++",
            code: """
// AIMLOCK - Native Plugin
#include <cmath>

struct Vector3 { float x, y, z; };

class AimLock {
public:
    float detectionRange = 600.0f;
    float lockStrength = 1.2f;
    float fovAngle = 25.0f;

    Vector3 FindClosest(Vector3 camPos, Vector3 camForward, Vector3* enemies, int count) {
        float bestScore = 999999.0f;
        Vector3 best = {0, 0, 0};
        for (int i = 0; i < count; i++) {
            Vector3 dir = Normalize(Subtract(enemies[i], camPos));
            float angle = Angle(camForward, dir);
            if (angle > fovAngle) continue;
            float dist = Distance(camPos, enemies[i]);
            float score = dist + angle * 2.0f;
            if (score < bestScore) {
                bestScore = score;
                best = enemies[i];
            }
        }
        return best;
    }

private:
    Vector3 Subtract(Vector3 a, Vector3 b) {
        return {a.x - b.x, a.y - b.y, a.z - b.z};
    }
    Vector3 Normalize(Vector3 v) {
        float len = sqrt(v.x*v.x + v.y*v.y + v.z*v.z);
        if (len == 0) return v;
        return {v.x/len, v.y/len, v.z/len};
    }
    float Distance(Vector3 a, Vector3 b) {
        Vector3 d = Subtract(a, b);
        return sqrt(d.x*d.x + d.y*d.y + d.z*d.z);
    }
    float Angle(Vector3 a, Vector3 b) {
        float dot = a.x*b.x + a.y*b.y + a.z*b.z;
        return acos(dot) * 57.2958f;
    }
};
"""
        ),
        CodeSnippet(
            name: "MICRO PULL JS",
            icon: "2",
            description: "Nhe tam cam ung muot",
            language: "JavaScript",
            code: """
// MICRO PULL - Touch Smooth
(function() {
  let lastX = 0, lastY = 0;
  const SMOOTH = 0.85;
  const THROTTLE = 8;
  let lastTime = 0;

  document.addEventListener('touchmove', function(e) {
    const now = performance.now();
    if (now - lastTime < THROTTLE) return;
    lastTime = now;
    const t = e.touches[0];
    if (!t) return;
    lastX = lastX + (t.clientX - lastX) * SMOOTH;
    lastY = lastY + (t.clientY - lastY) * SMOOTH;
    const target = e.target;
    if (target && target.style) {
      target.style.transform = 'translate(' + lastX + 'px, ' + lastY + 'px)';
    }
  }, { passive: true });
})();
"""
        ),
        CodeSnippet(
            name: "HEAD TRACK C#",
            icon: "3",
            description: "Bam dau du doan",
            language: "C#",
            code: """
// HEAD TRACK - Unity C#
using UnityEngine;

public class HeadTrackAdvanced : MonoBehaviour {
    public float range = 500f;
    public float trackSpeed = 12f;
    public float predictTime = 0.15f;
    public LayerMask enemyLayer;
    private Transform currentHead;
    private Vector3 lastHeadPos;
    private Vector3 headVelocity;
    private Camera cam;

    void Start() { cam = Camera.main; }

    void Update() {
        if (currentHead == null) FindHead();
        if (currentHead == null) return;
        Vector3 predicted = PredictHeadPosition(currentHead.position);
        Vector3 dir = (predicted - cam.transform.position).normalized;
        cam.transform.rotation = Quaternion.Lerp(
            cam.transform.rotation,
            Quaternion.LookRotation(dir),
            Time.deltaTime * trackSpeed);
    }

    void FindHead() {
        Collider[] hits = Physics.OverlapSphere(cam.transform.position, range, enemyLayer);
        float best = float.MaxValue;
        Transform bestHead = null;
        foreach (var h in hits) {
            Transform head = FindBone(h.transform, "head");
            if (head == null) continue;
            float d = Vector3.Distance(cam.transform.position, head.position);
            if (d < best) { best = d; bestHead = head; }
        }
        currentHead = bestHead;
    }

    Vector3 PredictHeadPosition(Vector3 current) {
        float dt = Time.deltaTime;
        if (dt > 0) headVelocity = (current - lastHeadPos) / dt;
        lastHeadPos = current;
        return current + headVelocity * predictTime;
    }

    Transform FindBone(Transform root, string name) {
        foreach (Transform t in root.GetComponentsInChildren<Transform>()) {
            if (t.name.ToLower().Contains(name)) return t;
        }
        return null;
    }
}
"""
        ),
        CodeSnippet(
            name: "TOUCH DELAY FIX",
            icon: "4",
            description: "Khu tre cam ung iOS",
            language: "Swift",
            code: """
// TOUCH DELAY FIX - Swift
import UIKit

class TouchOptimizer {
    static func applyTo(_ view: UIView) {
        view.isMultipleTouchEnabled = true
        view.isExclusiveTouch = false
        view.subviews.forEach { sub in
            sub.isUserInteractionEnabled = true
            if let scroll = sub as? UIScrollView {
                scroll.delaysContentTouches = false
                scroll.canCancelContentTouches = true
            }
        }
    }

    static func enableProMotion() {
        if #available(iOS 15.0, *) {
            let scenes = UIApplication.shared.connectedScenes
            for case let scene as UIWindowScene in scenes {
                scene.preferredFrameRateRange = CAFrameRateRange(
                    minimum: 60, maximum: 120, preferred: 120)
            }
        }
    }
}
"""
        ),
        CodeSnippet(
            name: "AIM ASSIST C++",
            icon: "5",
            description: "Keo muot + du doan",
            language: "C++",
            code: """
// AIM ASSIST - Native Engine
#include <cmath>
#include <algorithm>

class AimAssist {
private:
    float detectionRange = 600.0f;
    float aimSmoothness = 0.08f;
    float lockStrength = 1.2f;
    float predictionLeadTime = 0.12f;

public:
    struct Target {
        float x, y, z;
        float vx, vy, vz;
    };

    Target CalculateAim(Target* enemies, int count, float camX, float camY, float camZ) {
        Target best = {0, 0, 0, 0, 0, 0};
        float bestDist = 999999.0f;
        for (int i = 0; i < count; i++) {
            float dx = enemies[i].x - camX;
            float dy = enemies[i].y - camY;
            float dz = enemies[i].z - camZ;
            float dist = sqrt(dx*dx + dy*dy + dz*dz);
            if (dist > detectionRange) continue;
            if (dist < bestDist) { bestDist = dist; best = enemies[i]; }
        }
        best.x += best.vx * predictionLeadTime;
        best.y += best.vy * predictionLeadTime;
        best.z += best.vz * predictionLeadTime;
        return best;
    }

    float SmoothAngle(float current, float target) {
        return current + (target - current) * aimSmoothness * lockStrength;
    }
};
"""
        ),
        CodeSnippet(
            name: "RECOIL FIX",
            icon: "6",
            description: "Giam giat sung",
            language: "C#",
            code: """
// RECOIL FIX - Unity
using UnityEngine;

public class RecoilFix : MonoBehaviour {
    public float compensation = 0.8f;
    public float recoverySpeed = 4f;
    private Vector3 accumulatedRecoil;
    private Camera cam;

    void Start() { cam = Camera.main; }

    void LateUpdate() {
        if (accumulatedRecoil.magnitude > 0.001f) {
            cam.transform.localRotation *= Quaternion.Euler(-accumulatedRecoil);
            accumulatedRecoil = Vector3.Lerp(
                accumulatedRecoil, Vector3.zero,
                Time.deltaTime * recoverySpeed);
        }
    }

    public void OnShoot() {
        Vector3 recoil = new Vector3(
            Random.Range(-0.5f, 0.5f),
            Random.Range(0.5f, 1.5f),
            0) * compensation;
        accumulatedRecoil += recoil;
    }
}
"""
        ),
        CodeSnippet(
            name: "TRIGGER BOT",
            icon: "7",
            description: "Tu ban khi co target",
            language: "C++",
            code: """
// TRIGGER BOT - Native
#include <chrono>

class TriggerBot {
private:
    float detectionRange = 300.0f;
    float checkInterval = 0.02f;
    std::chrono::steady_clock::time_point lastCheck;

public:
    bool ShouldFire(float camX, float camY, float camZ,
                    float forwardX, float forwardY, float forwardZ,
                    float* enemyPositions, int enemyCount) {
        auto now = std::chrono::steady_clock::now();
        auto elapsed = std::chrono::duration<float>(now - lastCheck).count();
        if (elapsed < checkInterval) return false;
        lastCheck = now;
        for (int i = 0; i < enemyCount; i++) {
            float ex = enemyPositions[i * 3];
            float ey = enemyPositions[i * 3 + 1];
            float ez = enemyPositions[i * 3 + 2];
            float dx = ex - camX;
            float dy = ey - camY;
            float dz = ez - camZ;
            float dist = sqrt(dx*dx + dy*dy + dz*dz);
            if (dist > detectionRange) continue;
            float dot = (dx * forwardX + dy * forwardY + dz * forwardZ) / dist;
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
            description: "Du doan di chuyen dich",
            language: "C#",
            code: """
// PREDICTION - Unity Advanced
using UnityEngine;

public class Prediction {
    public float predictionTime = 0.25f;
    public float smoothing = 6f;
    public float maxPrediction = 8f;
    private Vector3 smoothedPredictPos;
    private Vector3 lastVelocity;

    public Vector3 GetPredictedPosition(Transform target, Rigidbody targetRb) {
        if (targetRb != null) {
            Vector3 predicted = target.position + targetRb.velocity * predictionTime;
            Vector3 delta = predicted - target.position;
            if (delta.magnitude > maxPrediction) {
                predicted = target.position + delta.normalized * maxPrediction;
            }
            smoothedPredictPos = Vector3.Lerp(
                smoothedPredictPos, predicted,
                Time.deltaTime * smoothing);
            lastVelocity = targetRb.velocity;
            return smoothedPredictPos;
        }
        return target.position;
    }
}
"""
        ),
        CodeSnippet(
            name: "FPS BOOST",
            icon: "9",
            description: "Toi uu hieu nang iOS",
            language: "Swift",
            code: """
// FPS BOOST - iOS Optimization
import UIKit
import QuartzCore

class PerformanceBooster {
    static func applyAll() {
        enable120Hz()
        UIApplication.shared.isIdleTimerDisabled = true
        optimizeLayers()
        URLCache.shared.removeAllCachedResponses()
    }

    private static func enable120Hz() {
        if #available(iOS 15.0, *) {
            let scenes = UIApplication.shared.connectedScenes
            for case let scene as UIWindowScene in scenes {
                scene.preferredFrameRateRange = CAFrameRateRange(
                    minimum: 60, maximum: 120, preferred: 120)
            }
        }
    }

    private static func optimizeLayers() {
        guard let window = UIApplication.shared.windows.first else { return }
        window.layer.shouldRasterize = true
        window.layer.rasterizationScale = UIScreen.main.scale
        window.layer.drawsAsynchronously = true
    }
}
"""
        )
    ]
}

// MARK: - CODE LIBRARY VIEW
struct CodeLibraryView: View {
    @State private var selectedSnippet: CodeSnippet?
    @State private var searchText: String = ""

    private var filteredSnippets: [CodeSnippet] {
        if searchText.isEmpty { return CodeLibrary.snippets }
        return CodeLibrary.snippets.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.language.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Theme.smoke2)
                TextField("Tim code...", text: $searchText)
                    .foregroundColor(.white)
                    .disableAutocorrection(true)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color.white.opacity(0.045))
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1), lineWidth: 1))

            HStack(spacing: 8) {
                StatBox(value: "\(CodeLibrary.snippets.count)", label: "SNIPPETS")
                StatBox(value: "5", label: "NGON NGU")
                StatBox(value: "PRO", label: "TIER")
            }

            SectionTitle(text: "CODE LIBRARY - \(filteredSnippets.count) MUC")

            ForEach(filteredSnippets) { snippet in
                CodeCard(snippet: snippet) {
                    selectedSnippet = snippet
                }
            }
        }
        .sheet(item: $selectedSnippet) { snippet in
            CodeDetailView(snippet: snippet)
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
                .foregroundColor(Theme.sea2)
            Text(label)
                .font(.system(size: 8, weight: .heavy))
                .kerning(1.2)
                .foregroundColor(Theme.smoke2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.045))
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.1), lineWidth: 1))
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
                            colors: [Theme.sea1.opacity(0.6), Theme.sea2.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing)
                    )
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.sea2.opacity(0.3), lineWidth: 1))

                VStack(alignment: .leading, spacing: 2) {
                    Text(snippet.name)
                        .font(.system(size: 12.5, weight: .black))
                        .foregroundColor(.white)
                    Text(snippet.description)
                        .font(.system(size: 10))
                        .foregroundColor(Theme.smoke2)
                }

                Spacer()

                VStack(spacing: 2) {
                    Text(snippet.language)
                        .font(.system(size: 9, weight: .heavy))
                        .kerning(1)
                        .foregroundColor(Theme.sea2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Theme.sea1.opacity(0.2))
                        .cornerRadius(6)
                    Text("\(snippet.code.count) chars")
                        .font(.system(size: 8))
                        .foregroundColor(Theme.smoke2)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.03))
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.08), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

struct CodeDetailView: View {
    let snippet: CodeSnippet
    @State private var copied: Bool = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            Theme.dark1.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    Text(snippet.icon)
                        .font(.system(size: 20, weight: .black))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(
                            LinearGradient(
                                colors: [Theme.sea1, Theme.sea2],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing)
                        )
                        .cornerRadius(10)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(snippet.name)
                            .font(.system(size: 15, weight: .black))
                            .foregroundColor(.white)
                        Text(snippet.language)
                            .font(.system(size: 10, weight: .heavy))
                            .kerning(1.5)
                            .foregroundColor(Theme.sea2)
                    }

                    Spacer()

                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(10)
                    }
                }
                .padding(16)
                .background(Theme.dark2)

                Divider().background(Color.white.opacity(0.1))

                ScrollView([.vertical, .horizontal], showsIndicators: false) {
                    Text(snippet.code)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(Theme.sea2)
                        .padding(16)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.6))

                Divider().background(Color.white.opacity(0.1))

                Button(action: {
                    UIPasteboard.general.string = snippet.code
                    copied = true
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { copied = false }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: copied ? "checkmark.circle.fill" : "doc.on.doc.fill")
                        Text(copied ? "DA COPY" : "COPY CODE")
                    }
                    .font(.system(size: 13, weight: .black))
                    .kerning(1)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(
                        LinearGradient(
                            colors: [Theme.sea1, Theme.sea2],
                            startPoint: .leading,
                            endPoint: .trailing)
                    )
                    .cornerRadius(12)
                }
                .buttonStyle(GradientButtonStyle())
                .padding(16)
                .background(Theme.dark2)
            }
        }
    }
}
