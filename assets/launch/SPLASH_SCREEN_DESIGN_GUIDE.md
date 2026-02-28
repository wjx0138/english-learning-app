# 启动屏设计规范

**项目**: English Learning App
**设计时间**: 2026-02-28
**版本**: v1.0

---

## 📱 启动屏尺寸要求

### Android

| 尺寸 | 设备类型 | 文件位置 |
|-----|---------|----------|
| 1080x1920px | xxhdpi (主要) | `drawable-xxhdpi/` |
| 1440x2560px | xxxhdpi | `drawable-xxxhdpi/` |
| 720x1280px | hdpi | `drawable-hdpi/` |

### iOS

| 尺寸 | 设备类型 | 文件位置 |
|-----|---------|----------|
| 1125x2436px | iPhone X/XS/11 Pro | `LaunchScreen.imageset/` |
| 1242x2688px | iPhone XS Max/11 Pro Max | `LaunchScreen.imageset/` |
| 828x1792px | iPhone XR/11 | `LaunchScreen.imageset/` |
| 1242x2208px | iPad Pro 12.9" | `LaunchScreen.imageset/` |
| 2048x2732px | iPad Pro 12.9" (@2x) | `LaunchScreen.imageset/` |

---

## 🎨 设计建议

### 设计元素

1. **布局**:
   - 居中对齐
   - 应用Logo (256x256px)
   - 应用名称
   - 可选: 标语/Slogan

2. **背景色**:
   - 主色: #4CAF50 (绿色)
   - 或渐变: #4CAF50 → #8BC34A
   - 或白色: #FFFFFF

3. **内容**:
```
┌────────────────────────┐
│                        │
│                        │
│          📚            │
│                        │
│   English Learning     │
│                        │
│   Master vocabulary    │
│                        │
│                        │
└────────────────────────┘
```

### 方案A: 简洁版

```
背景: 纯色 (#4CAF50)
Logo: 白色书本图标 (256x256)
标题: "English Learning" (白色, 大号)
副标题: "Master vocabulary efficiently" (白色, 小号)
```

### 方案B: 渐变版

```
背景: 绿色渐变 (#4CAF50 → #8BC34A)
Logo: 应用图标 (256x256, 带阴影)
标题: "English Learning" (白色, 加粗)
副标题: "Learn smarter, not harder" (白色)
```

### 方案C: 品牌版

```
背景: 白色 (#FFFFFF)
顶部装饰: 绿色渐变条
Logo: 彩色应用图标 (256x256)
标题: "English Learning" (深灰色 #333)
副标题: "63,000+ vocabulary words" (绿色 #4CAF50)
```

---

## 🛠️ 技术实现

### Android实现

#### 方法1: 使用drawable

**文件**: `android/app/src/main/res/drawable/launch_background.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- 背景色 -->
    <item android:drawable="@color/launch_background" />

    <!-- Logo -->
    <item>
        <bitmap
            android:gravity="center"
            android:src="@mipmap/ic_launcher_foreground" />
    </item>
</layer-list>
```

#### 方法2: 使用主题

**文件**: `android/app/src/main/res/values/styles.xml`

```xml
<style name="LaunchTheme" parent="@android:style/Theme.Light.NoTitleBar.Fullscreen">
    <item name="android:windowBackground">@drawable/launch_background</item>
    <item name="android:windowContentOverlay">@null</item>
</style>
```

### iOS实现

#### 使用LaunchScreen.storyboard

**文件**: `ios/Runner/Base.lproj/LaunchScreen.storyboard`

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<document type="com.apple.InterfaceBuilder3.CocoaTouch.Storyboard.XIB" version="3.0">
    <device id="retina6_1" orientation="portrait">
        <adaptation id="fullscreen"/>
    </device>
    <scenes>
        <scene sceneID="EHf-IW-A2E">
            <objects>
                <viewController id="01J-lp-oVM">
                    <view key="view" contentMode="scaleToFill" id="Ze5-6b-2t3">
                        <rect key="frame" x="0.0" y="0.0" width="375" height="667"/>
                        <autoresizingMask key="autoresizingMask" widthSizable="YES" heightSizable="YES"/>
                        <subviews>
                            <imageView clipsSubviews="YES" userInteractionEnabled="NO"
                                       contentMode="scaleAspectFit" horizontalHuggingPriority="251"
                                       verticalHuggingPriority="251" image="LaunchImage"
                                       translatesAutoresizingMaskIntoConstraints="NO" id="YRO-k0-Ey4">
                                <rect key="frame" x="87.5" y="268.5" width="200" height="200"/>
                            </imageView>
                            <label opaque="NO" userInteractionEnabled="NO" contentMode="left"
                                   horizontalHuggingPriority="251" verticalHuggingPriority="251"
                                   text="English Learning" textAlignment="center"
                                   lineBreakMode="tailTruncation" baselineAdjustment="alignBaselines"
                                   adjustsFontSizeToFit="NO" translatesAutoresizingMaskIntoConstraints="NO" id="GJd-Yh-RWb">
                                <rect key="frame" x="87.5" y="498.5" width="200" height="29"/>
                                <fontDescription key="fontDescription" type="boldSystem" pointSize="24"/>
                                <color key="textColor" white="1" alpha="1" colorSpace="custom" customColorSpace="genericGamma22GrayColorSpace"/>
                            </label>
                        </subviews>
                        <color key="backgroundColor" red="0.29803921570000003" green="0.68627450980000004" blue="0.31372549020000001" colorSpace="custom" customColorSpace="sRGB"/>
                        <constraints>
                            <constraint firstItem="YRO-k0-Ey4" firstAttribute="centerX" secondItem="Ze5-6b-2t3" secondAttribute="centerX" id="1a2-6s-vTC"/>
                            <constraint firstItem="YRO-k0-Ey4" firstAttribute="centerY" secondItem="Ze5-6b-2t3" secondAttribute="centerY" id="EXX-Uf-cTK"/>
                            <constraint firstItem="GJd-Yh-RWb" firstAttribute="centerX" secondItem="Ze5-6b-2t3" secondAttribute="centerX" id="5kL-Pi-0hX"/>
                            <constraint firstItem="GJd-Yh-RWb" firstAttribute="top" secondItem="YRO-k0-Ey4" secondAttribute="bottom" constant="30" id="uQo-1g-YTT"/>
                        </constraints>
                    </view>
                </viewController>
                <placeholder placeholderIdentifier="IBFirstResponder" id="iYj-Kq-Ea1" userLabel="First Responder" sceneMemberID="firstResponder"/>
            </objects>
            <point key="canvasLocation" x="53" y="375"/>
        </scene>
    </scenes>
    <resources>
        <image name="LaunchImage" width="200" height="200"/>
    </resources>
</document>
```

### Flutter实现 (native_splash)

**安装插件**:
```bash
flutter pub add flutter_native_splash
```

**配置**:
```yaml
flutter_native_splash:
  color: "#4CAF50"
  image: assets/icon/launcher_logo.png
  color_dark: "#1B5E20"
  image_dark: assets/icon/launcher_logo_dark.png

  android: true
  ios: true
  web: false

  android_12:
    image: assets/icon/android12_logo.png
    color: "#4CAF50"
```

**生成**:
```bash
flutter pub run flutter_native_splash:create
```

---

## 🎨 设计文件清单

### 需要创建的文件

- [ ] **launcher_logo.png** (1024x1024, 透明背景)
- [ ] **launcher_logo_dark.png** (1024x1024, 深色模式)
- [ ] **launch_background.png** (1080x1920, 背景图)
- [ ] **android12_logo.png** (512x512, Android 12+)

### 设计源文件

- [ ] **launch_screen.svg** (矢量源文件)
- [ ] **launch_screen.figma** (设计稿)

---

## ⏱️ 显示时长设置

### Android

**文件**: `android/app/src/main/res/values/styles.xml`

```xml
<style name="Theme.App.Starting" parent="Theme.SplashScreen">
    <item name="android:windowBackground">@drawable/launch_background</item>
</style>
```

**Activity**:
```kotlin
// Android 12+
class SplashActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // 延迟2-3秒后跳转
        Handler(Looper.getMainLooper()).postDelayed({
            startActivity(Intent(this, MainActivity::class.java))
            finish()
        }, 2500)
    }
}
```

### iOS

**文件**: `ios/Runner/Info.plist`

```xml
<key>UILaunchStoryboardName</key>
<string>LaunchScreen</string>
```

---

## ✅ 设计验收标准

- [ ] 在所有设备尺寸下显示正常
- [ ] 支持横竖屏切换
- [ ] 支持深色模式
- [ ] 启动后平滑过渡到主界面
- [ ] 无卡顿或闪烁
- [ ] Logo和文字清晰可读
- [ ] 背景色与应用主题一致

---

## 📝 后续步骤

1. **创建设计稿** (1小时)
   - 选择设计方案
   - 使用设计工具创建

2. **导出图片资源** (30分钟)
   - 导出各尺寸图片
   - 优化文件大小

3. **配置项目** (30分钟)
   - 添加图片到项目
   - 配置xml/storyboard
   - 运行flutter pub get

4. **测试验证** (30分钟)
   - 在不同设备上测试
   - 验证横竖屏
   - 验证深色模式

---

## 🎯 快速启动方案

### 使用生成器

```bash
# 1. 创建简单的Logo (256x256, PNG)
# 可以使用在线工具或设计软件

# 2. 配置flutter_native_splash
flutter pub add flutter_native_splash

# 3. 编辑pubspec.yaml
# 添加上述配置

# 4. 生成启动屏
flutter pub run flutter_native_splash:create

# 5. 测试
flutter run
```

---

**创建**: 2026-02-28
**设计师**: 待定
**状态**: 🚧 进行中
