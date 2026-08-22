---
name: Modern Dialog Animations
description: Ensure modern UI scale and fade transitions are used for Dialogs
---

# Rule: Modern Dialog Animations

Khi phát triển các giao diện có chứa hộp thoại (Dialog, Modal, Popup) trong Flutter, KHÔNG sử dụng `showDialog` mặc định vì hiệu ứng quá cứng nhắc.

BẮT BUỘC sử dụng `showGeneralDialog` với cấu trúc hiệu ứng Scale + Fade (Top Pick 2024-2025) để mang lại cảm giác chuyên nghiệp:

1. Sử dụng `transitionDuration: const Duration(milliseconds: 400)`.
2. Trong `transitionBuilder`, luôn wrap `child` bằng `Transform.scale` (dùng `Curves.easeOutBack.transform(anim1.value)`) và `Opacity` (dùng `anim1.value`).
3. Phần `child` bên trong Dialog/Container phải có bo góc `borderRadius: BorderRadius.circular(16)` và có shadow mịn để tạo chiều sâu.
