# Build APK Power & Volume trên GitHub

## Thông tin bản phát hành hiện tại

- Package: `com.floatingbutton.app`.
- APK local đã đối chiếu: `versionName` 2.0.0, `versionCode` 2.
- Ba APK local đã được xác nhận ký bằng `C:\Users\DELL\.android\debug.keystore`, alias `androiddebugkey`.
- SHA-256 chứng chỉ của các APK local và keystore: `6D982893A5CF58F3C82E8CF3ECA793013A49007AFF1670EE338484544A996D8C`.
- **Chưa xác nhận** APK thực tế đã upload lên Huawei/Amazon có cùng chứng chỉ. Huawei App Signing cũng có thể ký lại APK phân phối; cần đối chiếu chứng chỉ APK upload và APK phân phối với thông tin từng cửa hàng.
- Mã nguồn mới dùng `2.0.1+3` trong `pubspec.yaml` (versionName 2.0.1, versionCode 3). Trước khi phát hành, kiểm tra versionCode 3 lớn hơn mọi bản đã upload cho cùng package. Các bản sau phải tăng tiếp versionCode.

Giữ nguyên keystore hiện tại để không vô tình đổi chữ ký. Sao lưu an toàn bên ngoài máy, ưu tiên bản sao được mã hóa. Không commit keystore, chuỗi base64 hoặc mật khẩu vào Git và không chia sẻ chúng qua chat. Alias và fingerprint không phải khóa bí mật.

## Cấu hình GitHub Secrets (một lần)

Trên máy Windows chứa **đúng keystore cũ**, mở PowerShell và chép keystore dưới dạng base64 vào clipboard (chuỗi này chính là khóa nhạy cảm):

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("$env:USERPROFILE\.android\debug.keystore")) | Set-Clipboard
```

Trong GitHub repository: **Settings → Secrets and variables → Actions → New repository secret**, tạo:

1. `ANDROID_KEYSTORE_BASE64`: dán nội dung clipboard; sau đó xóa clipboard.
2. `ANDROID_KEYSTORE_PASSWORD`: mật khẩu của keystore hiện tại.
3. `ANDROID_KEY_PASSWORD`: mật khẩu của alias hiện tại.

Không gửi các giá trị này qua chat. Nếu dùng GitHub CLI để thiết lập, không đưa giá trị vào đối số dòng lệnh hay lịch sử shell. Secrets không tự chia sẻ sang fork, nên phải cấu hình tại đúng repository chạy workflow. Đảm bảo GitHub Actions được bật.

## Chạy build

1. Cấu hình secrets trước, rồi đưa thay đổi lên branch của repository trên GitHub. Mỗi lần push, workflow tự chạy. Nếu đã push trước khi cấu hình secrets, mở lần chạy bị lỗi và chọn **Re-run jobs**.
2. Trong **Actions → Android release APK**, mở lần chạy tương ứng với commit. Khi workflow đã có trên default branch, bạn cũng có thể chọn **Run workflow** để chạy thủ công trên branch mong muốn.
3. Workflow kiểm tra fingerprint keystore, chạy `flutter test`, build APK universal, kiểm tra chữ ký APK và tải artifact `Power-Volume-release-apk` lên GitHub Actions (lưu 14 ngày).
4. Tải artifact và kiểm tra trên thiết bị trước khi upload cửa hàng. Workflow không tự phát hành lên Huawei/Amazon.

Thiếu secrets hoặc fingerprint khác giá trị đã ghi thì build dừng; GitHub runner **không** tự tạo khóa mới để ký release. Trên máy local, nếu không truyền cấu hình ký ngoài, cấu hình build tiếp tục dùng debug keystore của máy đó; chỉ build trên máy có đúng keystore hoặc cấu hình rõ keystore đã sao lưu. Nếu APK upload trước đây không trùng fingerprint này, không phát hành bản mới cho đến khi xác định đúng cách cập nhật.

Khởi động lại foreground service phụ thuộc giới hạn Android/EMUI/HarmonyOS; kiểm thử bật/tắt, khởi động lại, cập nhật app và thông báo riêng trên thiết bị thực. Đồng thời kiểm tra trang privacy, tên nhà phát triển, và nội dung tiếng Trung trước khi gửi Huawei.
