#!/usr/bin/env python3
"""
使用PIL库直接生成应用图标
"""

from PIL import Image, ImageDraw, ImageFont, ImageOps
import os

def create_app_icon(size=1024, output_path='assets/icon/app_icon.png'):
    """创建应用图标"""
    print(f"🎨 正在生成 {size}x{size} 应用图标...")

    # 创建图像 - 绿色背景
    img = Image.new('RGB', (size, size), color='#4CAF50')
    draw = ImageDraw.Draw(img)

    # 尝试使用系统字体，如果没有则使用默认字体
    try:
        # macOS 系统字体
        font_size = int(size * 0.5)
        font = ImageFont.truetype('/System/Library/Fonts/Helvetica.ttc', font_size)
    except:
        try:
            font = ImageFont.truetype('/System/Library/Fonts/Arial.ttf', int(size * 0.5))
        except:
            # 使用默认字体
            font = ImageFont.load_default()
            print("⚠️  使用默认字体（建议安装Arial或Helvetica）")

    # 绘制文字 "EL"
    text = "EL"
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]

    # 居中对齐
    x = (size - text_width) // 2
    y = (size - text_height) // 2 - int(size * 0.05)

    # 绘制白色文字
    draw.text((x, y), text, fill='white', font=font)

    # 保存
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    img.save(output_path, 'PNG')
    print(f"✅ 图标已保存: {output_path}")

    return img

def create_launcher_logo(size=512, output_path='assets/icon/launcher_logo.png'):
    """创建启动屏Logo - 白色背景"""
    print(f"🎨 正在生成 {size}x{size} 启动屏Logo...")

    # 创建图像 - 白色背景
    img = Image.new('RGB', (size, size), color='white')
    draw = ImageDraw.Draw(img)

    # 尝试使用系统字体
    try:
        font_size = int(size * 0.4)
        font = ImageFont.truetype('/System/Library/Fonts/Helvetica.ttc', font_size)
    except:
        try:
            font = ImageFont.truetype('/System/Library/Fonts/Arial.ttf', int(size * 0.4))
        except:
            font = ImageFont.load_default()

    # 绘制绿色边框圆圈
    padding = int(size * 0.1)
    bbox = [padding, padding, size - padding, size - padding]
    draw.ellipse(bbox, outline='#4CAF50', width=int(size * 0.05))

    # 绘制文字
    text = "EL"
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]

    x = (size - text_width) // 2
    y = (size - text_height) // 2

    # 绘制绿色文字
    draw.text((x, y), text, fill='#4CAF50', font=font)

    # 保存
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    img.save(output_path, 'PNG')
    print(f"✅ Logo已保存: {output_path}")

    return img

def create_android12_logo(size=1024, output_path='assets/icon/android12_logo.png'):
    """创建Android 12+ Logo - 去背景，只有前景"""
    print(f"🎨 正在生成 {size}x{size} Android 12+ Logo...")

    # 创建透明背景图像
    img = Image.new('RGBA', (size, size), color=(0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # 绘制圆形 - 绿色
    padding = int(size * 0.1)
    bbox = [padding, padding, size - padding, size - padding]
    draw.ellipse(bbox, fill='#4CAF50')

    # 尝试使用系统字体
    try:
        font_size = int(size * 0.45)
        font = ImageFont.truetype('/System/Library/Fonts/Helvetica.ttc', font_size)
    except:
        try:
            font = ImageFont.truetype('/System/Library/Fonts/Arial.ttf', int(size * 0.45))
        except:
            font = ImageFont.load_default()

    # 绘制文字
    text = "EL"
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]

    x = (size - text_width) // 2
    y = (size - text_height) // 2 - int(size * 0.02)

    # 绘制白色文字
    draw.text((x, y), text, fill='white', font=font)

    # 保存
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    img.save(output_path, 'PNG')
    print(f"✅ Android 12+ Logo已保存: {output_path}")

    return img

def create_adaptive_foreground(size=1024, output_path='assets/icon/app_icon_foreground.png'):
    """创建自适应图标前景"""
    print(f"🎨 正在生成 {size}x{size} 自适应图标前景...")

    # 创建透明背景图像
    img = Image.new('RGBA', (size, size), color=(0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # 尝试使用系统字体
    try:
        font_size = int(size * 0.5)
        font = ImageFont.truetype('/System/Library/Fonts/Helvetica.ttc', font_size)
    except:
        try:
            font = ImageFont.truetype('/System/Library/Fonts/Arial.ttf', int(size * 0.5))
        except:
            font = ImageFont.load_default()

    # 绘制文字
    text = "EL"
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]

    x = (size - text_width) // 2
    y = (size - text_height) // 2

    # 绘制白色文字
    draw.text((x, y), text, fill='white', font=font)

    # 保存
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    img.save(output_path, 'PNG')
    print(f"✅ 自适应图标前景已保存: {output_path}")

    return img

def main():
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║          🎨 AI自动生成应用图标 🎨                              ║")
    print("╚══════════════════════════════════════════════════════════════╝")
    print()

    # 切换到项目目录
    project_dir = '/Users/wangjiaxin/Desktop/english/english_learning_app'
    os.chdir(project_dir)

    # 生成所有图标
    create_app_icon(1024, 'assets/icon/app_icon.png')
    create_adaptive_foreground(1024, 'assets/icon/app_icon_foreground.png')
    create_launcher_logo(512, 'assets/icon/launcher_logo.png')
    create_android12_logo(1024, 'assets/icon/android12_logo.png')

    print()
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print()
    print("✅ 所有图标已生成完成！")
    print()
    print("📁 生成的文件:")
    print("  • assets/icon/app_icon.png              (1024x1024)")
    print("  • assets/icon/app_icon_foreground.png   (1024x1024, 透明背景)")
    print("  • assets/icon/launcher_logo.png         (512x512, 白色背景)")
    print("  • assets/icon/android12_logo.png        (1024x1024, 透明背景)")
    print()
    print("🚀 下一步：运行以下命令生成所有尺寸:")
    print()
    print("  flutter pub get")
    print("  flutter pub run flutter_launcher_icons")
    print("  flutter pub run flutter_native_splash:create")
    print()

if __name__ == "__main__":
    main()
