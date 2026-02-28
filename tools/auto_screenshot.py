#!/usr/bin/env python3
"""
自动化截图生成脚本
使用模拟器自动化截图
"""

import os
import subprocess
import time

def run_screenshot(name, wait_seconds=3):
    """运行截图命令"""
    print(f"📸 截图: {name}")
    time.sleep(wait_seconds)

    # iOS截图
    try:
        subprocess.run([
            "xcrun", "simctl", "io", "booted", "screenshot",
            f"assets/screenshots/{name}.png"
        ], check=True)
        print(f"   ✅ iOS截图完成")
    except:
        print("   ⚠️  iOS截图失败，可能不是iOS模拟器")

    # Android截图
    try:
        subprocess.run([
            "adb", "shell", "screencap", "-p", "-p",
            f"/sdcard/{name}.png"
        ], check=True)
        subprocess.run([
            "adb", "pull", f"/sdcard/{name}.png",
            f"assets/screenshots/{name}.png"
        ], check=True)
        print(f"   ✅ Android截图完成")
    except:
        print("   ⚠️  Android截图失败，可能不是Android模拟器")

def main():
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║          📸 自动化截图生成工具 📸                                 ║")
    print("╚══════════════════════════════════════════════════════════════╝")
    print()

    # 创建截图目录
    os.makedirs("assets/screenshots", exist_ok=True)

    print("📋 截图清单:")
    print()

    screenshots = [
        ("01_home", "首页", 3),
        ("02_flashcard", "单词卡片学习", 3),
        ("03_typing", "打字练习", 3),
        ("04_progress", "学习进度", 3),
        ("05_courses", "课程选择", 3),
        ("06_gamification", "成就系统", 3),
        ("07_settings", "设置页面", 2),
        ("08_vocabulary_list", "词汇列表", 2),
        ("09_word_detail", "词汇详情", 2),
        ("10_quiz", "测验系统", 2),
    ]

    print("📝 使用说明:")
    print()
    print("  1. 确保模拟器正在运行:")
    print("     iOS:   open -a Simulator")
    print("     Android: flutter emulators --launch <emulator_id>")
    print()
    print("  2. 运行应用:")
    print("     flutter run")
    print()
    print("  3. 手动导航到各个页面，然后按Ctrl+C停止脚本")
    print("     或使用自动导航（如已实现）")
    print()
    print("  4. 每次截图前有3秒时间准备")
    print()

    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print()
    print("⚠️  准备开始截图...")
    print()
    print("按 Enter 键开始...")
    input()

    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print()

    for i, (filename, description, wait_time) in enumerate(screenshots, 1):
        print(f"\n[{i}/{len(screenshots)}] {description}")
        print(f"   请导航到该页面，然后按 Enter 继续...")
        input()
        run_screenshot(filename, wait_time)

    print()
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print()
    print("✅ 截图完成！")
    print(f"📁 保存位置: assets/screenshots/")
    print(f"📊 共完成 {len(screenshots)} 张截图")
    print()
    print("📝 后续步骤:")
    print("  1. 访问 https://mockuphone.com 添加设备框架")
    print("  2. 添加标注文字（可选）")
    print("  3. 导出最终版本")
    print()

if __name__ == "__main__":
    main()
