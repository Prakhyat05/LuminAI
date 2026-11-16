<div align="center">

# ⚡ LuminAI
### Elite Cross-Platform AI Personal Fitness Trainer
**On-Device Computer Vision • Biomechanical Kinematics • Generative AI Coaching**

---

[![Live Web Demo](https://img.shields.io/badge/🌐_Live_Demo-luminai--ai.web.app-00C853?style=for-the-badge&logo=googlechrome&logoColor=white)](https://luminai-ai.web.app)
[![Watch 1080p Video](https://img.shields.io/badge/🎬_Watch_Demo_Video-1080p_MP4-E50914?style=for-the-badge&logo=youtube&logoColor=white)](https://github.com/Prakhyat05/LuminAI/releases/download/v1.0.0/LuminAI-App-Walkthrough-16x9.mp4)
[![Download APK](https://img.shields.io/badge/📱_Download_APK-v1.0.0_arm64_(53.7MB)-1A1A2E?style=for-the-badge&logo=android&logoColor=white)](https://github.com/Prakhyat05/LuminAI/releases/download/v1.0.0/LuminAI-arm64-v1.0.0.apk)
[![GitHub Releases](https://img.shields.io/badge/📦_All_Releases-v1.0.0_Available-0969DA?style=for-the-badge&logo=github&logoColor=white)](https://github.com/Prakhyat05/LuminAI/releases/tag/v1.0.0)

<br/>

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=flat-square&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.4+-0175C2?style=flat-square&logo=dart&logoColor=white)](https://dart.dev)
[![Google ML Kit](https://img.shields.io/badge/Google_ML_Kit-Pose_Detection_30FPS-4285F4?style=flat-square&logo=google&logoColor=white)](https://developers.google.com/ml-kit)
[![Gemini 1.5 Flash](https://img.shields.io/badge/Google_Gemini-1.5_Flash_API-8E75B2?style=flat-square&logo=googlegemini&logoColor=white)](https://ai.google.dev)
[![Firebase Hosting](https://img.shields.io/badge/Firebase-Live_Hosting-FFCA28?style=flat-square&logo=firebase&logoColor=black)](https://luminai-ai.web.app)
[![SQLite](https://img.shields.io/badge/SQLite-Local_Persistence-003B57?style=flat-square&logo=sqlite&logoColor=white)](https://sqlite.org)
[![Build Size](https://img.shields.io/badge/APK_Size-53.7MB_(-62%25)-success?style=flat-square)](#-release-binaries--download-center)
[![Test Suite](https://img.shields.io/badge/Tests-8%2F8_Passed_(100%25)-success?style=flat-square)](#-testing--quality-assurance)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg?style=flat-square)](LICENSE)

</div>

---

## 🎬 Official 1080p Video Walkthrough

Click the player below to watch or download the complete 16:9 walkthrough video demonstrating the entire app flow, live computer vision tracking, and AI coaching functionalities:

<div align="center">

[![LuminAI 1080p Video Walkthrough](assets/images/video_preview.png)](https://github.com/Prakhyat05/LuminAI/releases/download/v1.0.0/LuminAI-App-Walkthrough-16x9.mp4)

*▶️ [Click here to download or stream the 1080p MP4 directly (4.55 MB)](https://github.com/Prakhyat05/LuminAI/releases/download/v1.0.0/LuminAI-App-Walkthrough-16x9.mp4)*

</div>

---

## 📖 Table of Contents
- [Overview & Value Proposition](#-overview--value-proposition)
- [Visual Showcase & Feature Highlights](#-visual-showcase--feature-highlights)
- [End-to-End User Flow](#-end-to-end-user-flow)
- [System Architecture](#-system-architecture)
- [Mathematical Formulation: Biomechanical Kinematics](#-mathematical-formulation-biomechanical-kinematics)
- [Pose Engine State Machine (FSM)](#-pose-engine-state-machine-fsm)
- [Supported Trackable Exercises](#-supported-trackable-exercises)
- [Recruiter & Developer Demo Mode](#-recruiter--developer-demo-mode)
- [Release Binaries & Download Center](#-release-binaries--download-center)
- [Local Development & Setup](#-local-development--setup)
- [Testing & Quality Assurance](#-testing--quality-assurance)
- [Security, Edge Privacy & Compliance](#-security-edge-privacy--compliance)
- [About the Author & License](#-about-the-author--license)

---

## 🎯 Overview & Value Proposition

**LuminAI** is an enterprise-grade, cross-platform personal fitness trainer that replaces invasive camera cloud streaming and rigid fitness apps with **100% on-device computer vision** and **adaptive generative AI**.

Traditional fitness apps suffer from three fundamental problems:
1. **Privacy Invasiveness:** Streaming raw video to remote cloud servers creates severe privacy and security risks.
2. **High Latency & Cloud Dependence:** Server-side pose estimation requires fast internet and incurs 200–500ms lag, causing delayed form corrections.
3. **Static Pre-Baked Content:** Hardcoded workout plans fail to adjust to fatigue, biomechanical limitations, and recovery needs.

**LuminAI solves this through an edge-first paradigm:**
- Runs Google ML Kit Pose Detection **strictly on-device at 30 FPS** with **<30ms inference latency**.
- Computes quadrant-aware joint trigonometry with **running-average smoothing** and **hysteresis debouncing** across 17 distinct exercises.
- Synthesizes personalized workout, nutrition, and recovery routines using **Google Gemini 1.5 Flash**, with seamless offline heuristic fallbacks.
- Delivers real-time corrective voice guidance via a **priority-queued Text-to-Speech (TTS) engine**.

---

## 📸 Visual Showcase & Feature Highlights

<table align="center" width="100%">
<tr>
<td width="50%" align="center">
<b>01. Live Biomechanical Pose Estimation</b><br/>
<img src="assets/images/preview_live_tracking.png" width="100%" alt="Live Pose Estimation"/>
<br/><i>33 skeletal landmarks tracked at 30+ FPS with sub-50ms kinematic angles and real-time audio voice cues.</i>
</td>
<td width="50%" align="center">
<b>02. Dynamic Command Dashboard</b><br/>
<img src="assets/images/preview_dashboard.png" width="100%" alt="Command Dashboard"/>
<br/><i>Centralized telemetry hub: active streaks, monthly consistency heatmap, daily targets & macro rings.</i>
</td>
</tr>
<tr>
<td width="50%" align="center">
<b>03. Gemini AI Workout Architect</b><br/>
<img src="assets/images/preview_ai_architect.png" width="100%" alt="Gemini Workout Architect"/>
<br/><i>Context-aware workout routine generation tailored to fatigue and muscle splits, with 1-tap live camera launch.</i>
</td>
<td width="50%" align="center">
<b>04. Precision Nutrition Command Center</b><br/>
<img src="assets/images/preview_nutrition.png" width="100%" alt="Nutrition Command Center"/>
<br/><i>Dynamic real-time macro rings (Protein, Carbs, Fats), instant modal meal logger & offline SQLite persistence.</i>
</td>
</tr>
<tr>
<td width="50%" align="center">
<b>05. Clinical Performance Analytics</b><br/>
<img src="assets/images/preview_analytics.png" width="100%" alt="Clinical Analytics"/>
<br/><i>6-axis joint compliance radar charts, longitudinal fatigue tracking & shareable clinical PDF reports.</i>
</td>
<td width="50%" align="center">
<b>06. Bio-Adaptive Onboarding Calibration</b><br/>
<img src="assets/images/preview_onboarding.png" width="100%" alt="Bio-Adaptive Onboarding"/>
<br/><i>Personalized anatomical calibration baseline for hypertrophy, calisthenics, and injury prevention.</i>
</td>
</tr>
</table>

---

## 🗺️ End-to-End User Flow

The following interactive wireflow illustrates the user's journey from onboarding to real-time workout tracking and clinical export:

```mermaid
flowchart TD
    classDef startEnd fill:#0F172A,stroke:#00E5FF,stroke-width:2px,color:#fff;
    classDef primary fill:#1E293B,stroke:#38BDF8,stroke-width:1px,color:#fff;
    classDef ai fill:#312E81,stroke:#818CF8,stroke-width:2px,color:#fff;
    classDef tracking fill:#064E3B,stroke:#10B981,stroke-width:2px,color:#fff;
    classDef data fill:#1F2937,stroke:#9CA3AF,stroke-width:1px,color:#fff;

    START(["🚀 App Launch"]) :::startEnd --> SPLASH["Screen 1: Splash Reveal<br/>(Brand & Hardware Sensor Check)"] :::primary
    
    SPLASH --> AUTH_CHECK{"Authenticated?"}
    AUTH_CHECK -- No --> ONBOARDING["Screen 2: Skeletal Calibration Onboarding<br/>(33-Point Setup & Audio Introduction)"] :::primary
    ONBOARDING --> AUTH_GATE["Screen 3: Auth Gateway<br/>(One-Tap 'Continue as Guest' or Phone OTP)"] :::primary
    AUTH_GATE --> GOALS["Screen 4: Goal Architect<br/>(Hypertrophy / Calisthenics / Athleticism)"] :::primary
    GOALS --> DASHBOARD
    
    AUTH_CHECK -- Yes / Guest --> DASHBOARD["Screen 5: Command Dashboard<br/>(Streaks, Monthly Heatmap, Daily Load & Macros)"] :::primary

    DASHBOARD --> PLAN_CHOICE{"User Action"}
    
    PLAN_CHOICE -- "Generate AI Routine" --> GEMINI_PLAN["Screen 6: Gemini AI Workout Architect<br/>(Context-Aware Sets, Reps & Muscle Splits)"] :::ai
    GEMINI_PLAN --> LIVE_CAM
    
    PLAN_CHOICE -- "Direct Workout" --> EXERCISE_LIB["Screen 7: Exercise Library<br/>(17 Biomechanical Movement Profiles)"] :::primary
    EXERCISE_LIB --> LIVE_CAM
    
    PLAN_CHOICE -- "Log Nutrition" --> NUTRITION["Screen 8: Nutrition Command<br/>(Dynamic Macro Rings & Modal Meal Logger)"] :::primary
    NUTRITION --> LOCAL_DB[("Local SQLite & Cloud Cache")] :::data
    
    PLAN_CHOICE -- "View Reports" --> ANALYTICS["Screen 9: Faculty Clinical Review<br/>(6-Axis Radar, Fatigue Curve & PDF Export)"] :::primary

    subgraph CoreVisionLoop ["⚡ Real-Time On-Device Vision Engine"]
        LIVE_CAM["Screen 10: Live AI Pose Tracking (/live-ai)<br/>(Camera / Studio Mode Toggle)"] :::tracking
        POSE_EST["Google ML Kit BlazePose<br/>(33 Landmarks @ 30 FPS)"] :::tracking
        KINEMATICS["Kinematic Joint Angles<br/>(atan2 Biomechanical Vectors)"] :::tracking
        FSM["Rep Counting State Machine<br/>(±5° Hysteresis Filter)"] :::tracking
        AUDIO_COACH["Real-Time Audio Coach<br/>(Priority-Queued Voice Feedback)"] :::tracking
        
        LIVE_CAM --> POSE_EST --> KINEMATICS --> FSM --> AUDIO_COACH
        AUDIO_COACH -.-> LIVE_CAM
    end

    FSM --> SESSION_RECAP["Screen 11: Session Recap<br/>(Calories Burned, Rep Count & Form Accuracy %)"] :::primary
    SESSION_RECAP --> LOCAL_DB
    LOCAL_DB --> DASHBOARD
```

---

## 🏛️ System Architecture

```mermaid
graph TD
    subgraph InputLayer ["1. Input & Sensor Streams"]
        CAM["Live Camera Stream (30 FPS)"]
        PED["Hardware Pedometer Stream"]
        SIM["Camera Fallback Simulator"]
    end

    subgraph VisionPipeline ["2. On-Device Vision & Kinematics"]
        MLKIT["Google ML Kit Pose Detector<br/>(33 3D Landmarks)"]
        GEOM["Quadrant-Aware Trigonometry<br/>(atan2 Biomechanical Angles)"]
        SMOOTH["Moving-Average Noise Filter<br/>(N = 5 Frames)"]
        FSM["Rep Phase State Machine<br/>(Hysteresis Thresholding)"]
    end

    subgraph AudioEngine ["3. Voice Coaching Engine"]
        TTS["Flutter TTS Service"]
        QUEUE["Priority Queue & Cooldown Ducking"]
    end

    subgraph DataLayer ["4. Hybrid Data Persistence"]
        SQLITE["SQLite Local Database<br/>(High-Throughput Telemetry)"]
        SPREFS["SharedPreferences<br/>(Local Settings & Fallback)"]
        FIRESTORE["Firebase Cloud Firestore<br/>(Multi-Device Sync)"]
    end

    subgraph GenerativeAI ["5. Generative AI Engine"]
        GEMINI["Google Gemini 1.5 Flash API<br/>(Dynamic Plan Synthesis)"]
        LOCALAI["Offline Heuristic Engine<br/>(Instant Rule-Based Fallback)"]
    end

    CAM --> MLKIT
    SIM --> MLKIT
    MLKIT --> GEOM
    GEOM --> SMOOTH
    SMOOTH --> FSM
    FSM --> QUEUE
    QUEUE --> TTS
    FSM --> SQLITE
    PED --> SQLITE
    SQLITE <--> FIRESTORE
    SPREFS <--> FIRESTORE
    GEMINI --> SQLITE
    LOCALAI --> SQLITE
```

---

## 📐 Mathematical Formulation: Biomechanical Kinematics

LuminAI calculates joint angles by treating anatomical landmarks as vectors in Euclidean space:

### 1. Vector Extraction
For any joint triplet formed by parent joint $A$, target joint vertex $B$, and child joint $C$ (e.g., Shoulder $\to$ Elbow $\to$ Wrist):

$$\vec{v}_{BA} = \begin{pmatrix} A_x - B_x \\ A_y - B_y \end{pmatrix}, \quad \vec{v}_{BC} = \begin{pmatrix} C_x - B_x \\ C_y - B_y \end{pmatrix}$$

### 2. Quadrant-Aware Angle Computation
Using the two-argument arctangent function to preserve quadrant orientation:

$$\theta_{BA} = \text{atan2}(v_{BA, y}, v_{BA, x}), \quad \theta_{BC} = \text{atan2}(v_{BC, y}, v_{BC, x})$$

$$\Delta\theta = |\theta_{BA} - \theta_{BC}|$$

$$\theta_{\text{joint}} = \begin{cases} \Delta\theta & \text{if } \Delta\theta \le \pi \\ 2\pi - \Delta\theta & \text{if } \Delta\theta > \pi \end{cases}$$

### 3. Running-Average Noise Smoothing
To filter landmark jitter caused by camera sensor noise and motion blur:

$$\bar{\theta}_t = \frac{1}{N} \sum_{i=0}^{N-1} \theta_{t-i}, \quad N = 5 \text{ frames}$$

### 4. Hysteresis State Transition
To eliminate bounce around inflection points during rapid rep repetitions:

$$\text{Transition } \text{Inflection} \to \text{Extension} \iff \bar{\theta} \le (\theta_{\text{inflection}} - \epsilon)$$

$$\text{Transition } \text{Extension} \to \text{Completed Rep} \iff \bar{\theta} \ge (\theta_{\text{extension}} + \epsilon), \quad \epsilon = 5.0^\circ$$

---

## 🔄 Pose Engine State Machine (FSM)

The Finite State Machine enforces rigorous form criteria before incrementing any repetition counter:

```mermaid
stateDiagram-v2
    [*] --> Idle: Session Initialized
    Idle --> Calibrating: Landmarks in Frame
    Calibrating --> Tracking: Calibration Confirmed (>85% Confidence)
    
    state Tracking {
        [*] --> Extension: Neutral Starting Stance
        Extension --> InflectionPhase: Joint Angle < (Inflection - 5°)
        InflectionPhase --> ExtensionPhase: Joint Angle > (Extension + 5°)
        ExtensionPhase --> RepCounted: Full Range of Motion Verified
        RepCounted --> Extension: Trigger Voice Cue & Increment
    }
    
    Tracking --> FormWarning: Joint Deviation Detected (>15° Error)
    FormWarning --> Tracking: Form Corrected
    Tracking --> Paused: User Pause / Out of Frame
    Paused --> Tracking: In-Frame Resume
    Tracking --> Completed: Target Reps / Sets Achieved
    Completed --> [*]
```

---

## 📱 Supported Trackable Exercises

LuminAI supports 17 exercise profiles categorized by muscle group:

| Muscle Group | Exercise | Primary Biomechanical Joint | Target Range | Form Criteria Monitored | Real-Time Voice Cue |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Upper Body** | Bicep Curls | Left / Right Elbow | $45^\circ \longleftrightarrow 160^\circ$ | Full extension without shoulder swing | *"Keep elbows pinned to your sides"* |
| | Push-ups | Elbows & Torso | $70^\circ \longleftrightarrow 165^\circ$ | Chest depth & straight back plane | *"Keep your core tight, don't sag hips"* |
| | Shoulder Press | Elbows & Deltoids | $80^\circ \longleftrightarrow 170^\circ$ | Vertical press trajectory | *"Lock out overhead without arching back"* |
| | Lateral Raises | Shoulder Abduction | $20^\circ \longleftrightarrow 90^\circ$ | Arm parallel to ground, no trap shrug | *"Lead with your elbows, control the descent"* |
| | Tricep Dips | Elbow Flexion | $90^\circ \longleftrightarrow 165^\circ$ | 90-degree elbow lock at dip bottom | *"Descend to 90 degrees"* |
| | Pull-ups | Elbow & Lat Hinge | $50^\circ \longleftrightarrow 170^\circ$ | Chin over bar, full dead-hang | *"Full range of motion, avoid kipping"* |
| **Lower Body** | Barbell / Bodyweight Squats | Left / Right Knees | $80^\circ \longleftrightarrow 170^\circ$ | Femur parallel to floor, knee alignment | *"Push through your heels, thighs parallel"* |
| | Walking Lunges | Lead Knee & Trail Knee | $85^\circ \longleftrightarrow 165^\circ$ | 90-degree front knee, upright spine | *"Keep your front knee behind your toes"* |
| | Calf Raises | Ankle Plantarflexion | $120^\circ \longleftrightarrow 165^\circ$ | Maximum calf peak contraction | *"Hold the contraction at the top"* |
| | Glute Bridges | Hip Extension | $130^\circ \longleftrightarrow 180^\circ$ | Full pelvic lock at top of motion | *"Squeeze glutes at peak extension"* |
| **Core & Cardio** | Forearm Plank | Hip & Spine Linearity | $170^\circ \longleftrightarrow 180^\circ$ | Zero hip sag or excessive pike | *"Maintain a straight spine line"* |
| | Abdominal Crunches | Torso-Hip Angle | $110^\circ \longleftrightarrow 160^\circ$ | Shoulder blade lift, cervical neck safety | *"Contract your abs, don't pull your neck"* |
| | Jumping Jacks | Shoulder & Hip Span | $30^\circ \longleftrightarrow 140^\circ$ | Full overhead arm sweep & foot spread | *"Stay light on the balls of your feet"* |
| | Mountain Climbers | Alternating Hip Drives | $60^\circ \longleftrightarrow 160^\circ$ | Knee drive cadence & steady plank posture | *"Drive knees forward, maintain tempo"* |
| | Burpees | Multi-Phase Compound | Compound | Full ground touch to explosive jump | *"Full chest to ground, jump straight up"* |

---

## 🎮 Recruiter & Developer Demo Mode

Evaluating LuminAI is seamless even without hardware cameras or account setup:

1. **One-Tap Guest Mode:** On the sign-in screen, tap **"Continue as Guest"** for instant access without entering credentials.
2. **Camera Fallback Simulator:** If no camera is detected or when running on desktop/emulators, LuminAI automatically activates an algorithmic pose generator simulating authentic human kinematic cycles for testing reps and voice coaching.
3. **Live Web Browser App:** Test the entire UI, workout logging, AI generation, and settings directly in your browser without installing anything:  
   👉 **[https://luminai-ai.web.app](https://luminai-ai.web.app)** *(Mirror: [https://luminai-fitness.web.app](https://luminai-fitness.web.app))*

---

## 📦 Release Binaries & Download Center

Official production builds are hosted on [GitHub Releases (v1.0.0)](https://github.com/Prakhyat05/LuminAI/releases/tag/v1.0.0):

| Release Asset | Platform / Type | File Size | Description | Direct Download |
| :--- | :--- | :--- | :--- | :---: |
| **`LuminAI-App-Walkthrough-16x9.mp4`** | **Official 1080p Video** | **4.55 MB** | **Complete 16:9 walkthrough video demonstrating live features** | [🎬 Watch / Download](https://github.com/Prakhyat05/LuminAI/releases/download/v1.0.0/LuminAI-App-Walkthrough-16x9.mp4) |
| **`LuminAI-arm64-v1.0.0.apk`** | **Android 64-bit (`arm64-v8a`)** | **53.7 MB** | **Recommended for >99% of modern Android smartphones** | [⬇️ Download APK](https://github.com/Prakhyat05/LuminAI/releases/download/v1.0.0/LuminAI-arm64-v1.0.0.apk) |
| **`LuminAI-universal-v1.0.0.apk`** | Android Universal (Fat Binary) | 139.6 MB | All Android architectures combined | [⬇️ Download APK](https://github.com/Prakhyat05/LuminAI/releases/download/v1.0.0/LuminAI-universal-v1.0.0.apk) |
| **`LuminAI-arm32-v1.0.0.apk`** | Android 32-bit (`armeabi-v7a`) | 46.0 MB | Older legacy Android smartphones | [⬇️ Download APK](https://github.com/Prakhyat05/LuminAI/releases/download/v1.0.0/LuminAI-arm32-v1.0.0.apk) |
| **`LuminAI-x86_64-v1.0.0.apk`** | Android x86_64 | 53.1 MB | Android Studio Emulators & Chromebooks | [⬇️ Download APK](https://github.com/Prakhyat05/LuminAI/releases/download/v1.0.0/LuminAI-x86_64-v1.0.0.apk) |
| **`LuminAI-web-v1.0.0.zip`** | Web Static Assets (SPA) | 7.6 MB | Self-hosting on Firebase, Netlify, or Apache | [⬇️ Download ZIP](https://github.com/Prakhyat05/LuminAI/releases/download/v1.0.0/LuminAI-web-v1.0.0.zip) |

---

## 🛠️ Local Development & Setup

### Prerequisites
- **Flutter SDK:** `>= 3.4.3 < 4.0.0` ([Install Flutter](https://docs.flutter.dev/get-started/install))
- **Dart SDK:** `>= 3.4.0`
- **Android Studio / VS Code** with Flutter extensions
- **Device:** Physical Android / iOS device (recommended for camera testing) or modern browser for Web

### Installation Steps

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Prakhyat05/LuminAI.git
   cd LuminAI
   ```

2. **Fetch dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run locally:**
   ```bash
   # Run with Gemini AI Generative Plan support:
   flutter run --dart-define=GEMINI_API_KEY="your_gemini_api_key"

   # Or run with built-in heuristic offline AI plan generation:
   flutter run
   ```

4. **Build Production Release Binaries:**
   ```bash
   # Build optimized split-per-abi APKs (-62% file size):
   flutter build apk --split-per-abi --release --dart-define=GEMINI_API_KEY="your_key"

   # Build Web release:
   flutter build web --release --dart-define=GEMINI_API_KEY="your_key"
   ```

---

## 🧪 Testing & Quality Assurance

LuminAI enforces rigorous quality verification via unit and widget tests:

```bash
flutter test
```

**Verified Test Coverage (8/8 Passed):**
- `calculateJointAngle` 90-degree right angle trigonometric precision.
- `calculateJointAngle` 180-degree collinear vector evaluation.
- `calculateJointAngle` 45-degree acute angle calculation.
- `PoseEngine` state machine initialization and rep counting resets.
- Exercise profile biomechanical mappings (Elbow, Knee, Hip, Shoulder).
- Empty/corrupted landmark frame fault-tolerance.
- Widget tree startup and theme validation.

---

## 🔒 Security, Edge Privacy & Compliance

- **100% On-Device Computer Vision:** Video feeds and camera frames are processed directly in device volatile memory by ML Kit and discarded immediately. **Zero camera frames are ever saved to disk or transmitted to any server.**
- **Secret Scanning Compliant:** No private API keys or certificates are tracked in Git. Sensitive tokens are injected via compile-time `--dart-define` parameters.
- **Offline Resilience:** Functions completely without an internet connection, storing telemetry in local SQLite and using offline rule-based AI plan generation.

---

## 📄 About the Author & License

Developed with ❤️ by **Prakhyat** as a Major Project.

- **GitHub:** [@Prakhyat05](https://github.com/Prakhyat05)
- **Repository:** [https://github.com/Prakhyat05/LuminAI](https://github.com/Prakhyat05/LuminAI)
- **Live Demo:** [https://luminai-ai.web.app](https://luminai-ai.web.app) *(Mirror: [https://luminai-fitness.web.app](https://luminai-fitness.web.app))*

This project is open-source under the **[MIT License](LICENSE)**.
